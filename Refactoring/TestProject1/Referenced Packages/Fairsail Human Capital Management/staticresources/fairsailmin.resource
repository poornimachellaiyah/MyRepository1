'use strict';

if (!window.wxDependencies) {
	window.wxDependencies = [];
}

angular
	.module('fairsailWX', [
		//'angular-loading-bar',
		'ngTouch',
		'ngCookies',
		'ngResource',
		'ngRoute',
		'ui.bootstrap',
		'ui.bootstrap.custom.accordion',
		'ui.bootstrap.tabs',
		'pascalprecht.translate',
		'ngSanitize',
		'duScroll',
		'fairsailWXFilters',
		'ngLocale',
		'ui.tinymce',
		'chart.js'
	].concat(window.wxDependencies))
	.config(['$routeProvider', '$locationProvider', '$translateProvider', 'AppConstants', '$compileProvider', function ($routeProvider, $locationProvider, $translateProvider, AppConstants, $compileProvider) {
		if (window.resourcePath) {
			for (var key in AppConstants) {
				if (AppConstants.hasOwnProperty(key) && typeof AppConstants[key] === 'string') {
					AppConstants[key] = AppConstants[key].replace('REPLACESTATICRESOURCE', window.resourcePath);
				}
			}
		}

		$routeProvider
			.when('/', {
				templateUrl: AppConstants.MAINVIEWSHTML,
				controller: 'MainCtrl'
			})
			.when('/teammember/:teamMemberId', {
				templateUrl: AppConstants.DEFAULTTEAMMEMBERVIEWSHTML,
				controller: 'TeamMemberCtrl'
			})
			.when('/teammember/:teamMemberId/services/:categoryId', {
				// template: '<p>Show Service</p>'
				templateUrl: AppConstants.SHOWCATEGORYVIEWSHTML,
				controller: 'ShowCategoryCtrl'
			})
			.when('/teammember/:teamMemberId/team/:teamName/services/:categoryId', {
				templateUrl: AppConstants.SHOWCATEGORYVIEWSHTML,
				controller: 'ShowCategoryCtrl'
			})
			.when('/teammember/:teamMemberId/services/:categoryId/processes/:processId', {
				//templateUrl: 'views/showprocess.html',
				templateUrl: AppConstants.SHOWPROCESSVIEWSHTML,
				controller: 'ShowProcessCtrl'
			})
			.when('/teammember/:teamMemberId/team/:teamName/services/:categoryId/processes/:processId', {
				//templateUrl: 'views/showprocess.html',
				templateUrl: AppConstants.SHOWPROCESSVIEWSHTML,
				controller: 'ShowProcessCtrl'
			})
			.when('/teammember/:teamMemberId/orgchart', {
				templateUrl: AppConstants.ORGCHARTVIEWSHTML
			})
			.when('/teammember/:teamMemberId/actions', {
				templateUrl: AppConstants.ACTIONSVIEWSHTML,
				controller: 'ActionsCtrl'
			})
			.when('/teammember/:teamMemberId/search', {
				templateUrl: AppConstants.SEARCHVIEWSHTML,
				controller: 'SearchCtrl'
			})
			.otherwise({
				redirectTo: '/'
			});

		var defaultTranslations = {
			'fCP_TITLE': ' ',
			'fCP_CURRENT_LANGUAGE': ' '
		};

		$translateProvider.translations('default_lang', defaultTranslations);

		$translateProvider.useLoader('TranslationLoaderFactory', {});

		$translateProvider.preferredLanguage('default_lang');

		$compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|sip|file|skype):/);

	}]);

angular.module('fairsailWXFilters', []);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('ActionsCtrl', ['$scope', 'AppConstants', 'ActionsHelper', 'UserFactory', 'ContextFactory', 'CategoryFactory', 'ProcessDataFactory', '$modal', '$q', '$filter', '$log', '$timeout',
		function ($scope, AppConstants, ActionsHelper, UserFactory, ContextFactory, CategoryFactory, ProcessDataFactory, $modal, $q, $filter, $log, $timeout) {

			var operationModalOpen = false;
			var pendingActions = 0;
			var pendingActionsTimeout;

			function confirmWarning(errors) {
				$modal.open({
					templateUrl: AppConstants.CONFIRMWARNINGVIEWSHTML,
					backdrop: 'static',
					controller: 'ConfirmDialogCtrl',
					resolve: {
						modalParams: function () {
							return {
								errors: errors,
								operationScope: $scope.$parent
							};
						}
					}
				});
			}

			function actionCompleted() {
				$log.debug('Pending actions = ' + pendingActions);
				if (pendingActions > 0) {
					pendingActions--;

					if (pendingActions == 0) {
						$timeout.cancel(pendingActionsTimeout);
						doRefresh('process_and_actions');
					}
				}
			}

			function doRefresh(refresh) {
				if (!refresh) {
					$log.error('no refresh');
					return;
				}

				if (refresh == 'page' || refresh == 'page_and_actions') {
					// clear the caches
					ActionsHelper.clear();
					CategoryFactory.clear();
					refreshActions();

					UserFactory.loaded();
				} else if (refresh == 'process' || refresh == 'item' || refresh == 'process_and_actions' || refresh == 'item_and_actions') {
					ActionsHelper.clear();
					refreshActions();
				} else if (refresh == 'none' || refresh == 'continue') {
					// do nothing
				} else {
					$log.error('Unsupported refresh option' + operation.refresh);
				}
			}

			function refreshActions() {
				$log.debug('ActionsCtrl:refreshActions');

				var deferred = ActionsHelper.getActions(ContextFactory.teamMemberId);
				deferred.$promise.then( function(actions) {
					$scope.actions = actions.allActions;
					$scope.transformedActions = actions.transformedActions;
					$scope.otherActions = actions.otherActions;
				});
			}

			function cloneAction(category, instance, action) {
				action.used = true;
				var newAction = jQuery.extend(true, {}, action);

				newAction.serviceName = category.label;
				newAction.serviceId = category.id;
				newAction.processName = instance.label;
				newAction.processId = instance.id;
				newAction.ticked = false;

				return newAction;

			}

			function openModalFrameWithData(processId, params, operation, data) {
				$scope.processItem = {id: params.processId};
				var modalInstance = $modal.open({
					templateUrl: AppConstants.MODALIFRAMEVIEWSHTML,
					controller: 'ModalInstanceCtrl',
					backdrop: 'static',
					windowClass: 'app-modal-window',
					resolve: {
						modalParams: function () {
							return {
								teamMember: {name: params.teamMemberName, id: params.teamMemberId},
								processId: processId,
								itemId: params.itemId,
								childId: params.childId,
								items: data,
								urlFrame: params.urlFrame,
								titleModal: params.titleModal,
								operation: operation,
								parentScope: $scope
							};
						}
					}
				});

				modalInstance.result.then(function (result) {
					$log.debug('modal closed');

					operationModalOpen = false;
				}, function () {
					operationModalOpen = false;
				});
			};

			function openModalWithData(processId, params, operation, data) {
				$scope.processItem = {id: params.processId};
				var modalInstance = $modal.open({
					templateUrl: AppConstants.MODALVIEWSHTML,
					// templateUrl: operation.url,
					controller: 'ModalInstanceCtrl',
					backdrop: 'static',
					resolve: {
						modalParams: function () {
							return {
								teamMember: {name: params.teamMemberName, id: params.teamMemberId},
								processId: processId,
								itemId: params.itemId,
								childId: params.childId,
								items: data,
								operation: operation,
								parentScope: $scope
							};
						}
					}
				});

				modalInstance.result.then(function (result) {
					$log.debug('modal closed');

					operationModalOpen = false;
				}, function () {
					operationModalOpen = false;
				});
			};

			function getOperationData(processId, itemId, operationId, teamMemberId) {

				// build query properties
				var props = {
					teamMemberId: teamMemberId,
					processId: processId,
					dataType: 'operations',
					itemId: itemId,
					dataId: operationId
				};

				return ProcessDataFactory.get(props);
			};

			$scope.refreshProcess = function(){
				doRefresh('process_and_actions');
			}

			$scope.showProcess = function (action) {

				if (!action) {
					//$log.debug('Undefined action');
					return;
				}

				ContextFactory.setYourPath(action.teamMemberId, action.serviceId, action.processId);
			};

			$scope.showTeamMember = function (action) {

				if (!action) {
					//$log.debug('Undefined action');
					return;
				}

				ContextFactory.selectTeamMember(action.teamMemberId, true);
			};

			$scope.doAction = function (action, inBulk) {


				if (operationModalOpen) {
					$log.debug('Modal already open');
					return;
				}

				if (action.processProxyId) {
					action = jQuery.extend(true, {}, action);
					action.processId = action.processProxyId;
				}

				if (inBulk) {
					if (action.canDoInBulk) {
						$log.debug('BULK ACTION');
						$scope.doOperation(action.operationId, undefined, action.itemId, undefined, 'none', action.teamMemberId, action.processId); //don't refresh per action
					} else {
						$log.error('Attempt to do non bulk action in bulk')
					}
				} else {
					if (action.requiresForm) {
						// get the operation

						var operationdata = getOperationData(action.processId, action.itemId, action.operationId, action.teamMemberId);

						operationdata.$promise.then(function (data) {
							var params = {
								processId: action.processId,
								itemId: action.itemId,
								teamMemberId: action.teamMemberId,
								teamMemberName: action.teamMemberName
							};
							var operation = {id: action.operationId, url: action.url};
							//console.log('ACTTION: ' + action.flags.isClassic);
							if (action.flags != undefined && action.flags.isClassic == 'true') {
								params.urlFrame = action.url;
								params.titleModal = action.action + " " + action.processType;
								openModalFrameWithData(action.processId, params, operation, data);
							} else {
								openModalWithData(action.processId, params, operation, data);

							}
						}, function () {
							// cancel
							operationModalOpen = false;
						});

						operationModalOpen = true;
					}
					else {
						$scope.doOperation(action.operationId, undefined, action.itemId, undefined, undefined, action.teamMemberId, action.processId);
					}
				}
			}

			$scope.getOperationData = function (params, teamMemberId) {

				// build query properties
				var props = {
					teamMemberId: teamMemberId ? teamMemberId : ContextFactory.teamMemberId,
					processId: $scope.processItem.id,
					dataType: 'operations'
				};

				for (var key in params) {

					$log.debug('forwarding query parameter ' + key + ' = ' + params[key]);

					if (params.hasOwnProperty(key)) {
						props[key] = params[key];
					}
				}

				return ProcessDataFactory.get(props);
			};

			$scope.doBulkActions = function () {
				angular.forEach($scope.transformedActions, function (service) {     //iterate over all actions in transformedActions
					angular.forEach(service.processes, function (process) {
						angular.forEach(process.actions, function (action) {
							if (action.ticked == true) {                             //if action is ticked then do it
								$scope.doAction(action, true);
								pendingActions++;
							}
						})
					})
				});

				if (pendingActions > 0) {
					if (pendingActionsTimeout) {
						$timeout.cancel(pendingActionsTimeout);
					}

					pendingActionsTimeout = $timeout(function () {
						pendingActions = 1;
						actionCompleted();
						pendingActionsTimeout = undefined;
					}, 10000);

				}
			};


			$scope.clearOtherProcessItems = function (processId) {
				$scope.selectedProcess = processId;
				angular.forEach($scope.transformedActions, function (service) {     //iterate over all actions in transformedActions
					angular.forEach(service.processes, function (process) {
						angular.forEach(process.actions, function (action) {
							if (action.processId != processId) {    //clear actions previously ticked in other processes
								action.ticked = false;
							}
						})
					})
				})
			};


			$scope.processHasTickedItems = function (processId) {
				$scope.countTickedItems = 0;
				angular.forEach($scope.transformedActions, function (service) {     //iterate over all actions in transformedActions
					angular.forEach(service.processes, function (process) {
						angular.forEach(process.actions, function (action) {
							if (action.processId == processId && action.ticked == true) {    //check for ticked actions in the selected process
								$scope.countTickedItems++;
							}
						})
					})
				})
				if ($scope.countTickedItems > 0) {
					return true;
				}
				else {
					return false;
				}
			};

			$scope.doOperation = function (operationId, data, itemId, childId, refresh, teamMemberId, processId) {
				var warnAndInfoShown = false;
				if ($scope.errors && (($scope.errors.warnings && $scope.errors.warnings.length>0) || ($scope.errors.information && $scope.errors.information.length>0))) {
					warnAndInfoShown = true;
				}

				if (!processId) {
					processId = $scope.processItem.id;
				}

				var d = $q.defer();
				var operation = new ProcessDataFactory();
				operation.params = data;
				operation.$save({
					"teamMemberId": teamMemberId,
					"processId": processId,
					"dataType": "operations",
					"dataId": operationId,
					"itemId": itemId
				}).then(function (result) {
					if (result.result) {
						$log.debug('Refreshing after operation ' + operationId);

						if (!refresh) {
							refresh = result.refresh ? result.refresh : 'process_and_actions';
						}

						$log.debug('Performing refresh: ' + refresh);
						// update view
						doRefresh(refresh);

						if ((result.warnings || result.information) && refresh != 'next' && !warnAndInfoShown) {
							$timeout(function () {
								confirmWarning(result);
							}, 0);
						}
					}
					d.resolve(result);
					actionCompleted();
				}, function (error) {
					$log.error('operation failed ' + error);
					actionCompleted();
				});
				return d;

			};

			ContextFactory.callWhenLoaded(function () {
				refreshActions();
			});


			$scope.$watch(function () {
					return ActionsHelper.isClear();
				},
				function (newVal, oldVal) {
					if (newVal && newVal != oldVal) {
						refreshActions();
					}
				}
			);
		}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller("AsyncDrilldownController", ["$scope", "ProcessDataFactory", "$routeParams", function ($scope, ProcessDataFactory, $routeParams) {


    $scope.openList = function (teamMember,selectedTab) {

      if (teamMember.drill == undefined) {
        teamMember.drill = false;
      }

      if (teamMember.drill) {
        teamMember.drill = false;
      } else {
          var deferredProcData = ProcessDataFactory.query({
            teamMemberId: teamMember.id,
            processId: $routeParams.processId,
            dataType: 'views',
            dataId: $scope.processItem.detailViewName,
            team: $routeParams.teamName,
            itemId: selectedTab
           }
          );
          deferredProcData.$promise.then(function (data) {
            if (data.teamMember) {
              teamMember.teamMembers = data.teamMember.teamMembers;
              teamMember.drill = true;
            }
          });
      }

    };

  }]);

/* EOF */
'use strict';

var mod = angular.module('fairsailWX');

mod.controller('AsyncTabController', ['$scope', '$filter', '$translate', 'ProcessDataFactory', '$routeParams', '$log', 'ContextFactory',
  function ($scope, $filter, $translate, ProcessDataFactory, $routeParams, $log, ContextFactory) {

  $log.debug('creating controller');


  $scope.$watch('processItem.data', function (newVal, oldVal) {
    if (newVal && newVal.teamMember) {
      var data = newVal;
      $scope.tabs = data.tabs;
      if (!oldVal) $scope.selectedTab = data.tabs[0];
      $scope.teamMember = data.teamMember;
      $scope.teamMember.drill = true;
    }
  });

  $scope.isSet = function (checkTab) {
    return $scope.selectedTab === checkTab;
  };

  $scope.setTab = function (tab) {
    $scope.selectedTab = tab;
    $scope.teamMembers = [];
    var query = {
      teamMemberId: ContextFactory.teamMemberId,
      processId: $routeParams.processId,
      dataType: 'views',
      dataId: $scope.processItem.detailViewName,
      team: $routeParams.teamName,
      itemId: tab
    };

    var deferredProcData = ProcessDataFactory.query(query);
    deferredProcData.$promise.then(function (data) {
      $scope.processItem.data = data;
    });
  };


}]);

/* EOF */
'use strict';

angular.module('fairsailWX')

    .controller('CalendarCtrl', ['$scope', '$locale', '$window', 'pickadateUtils','$timeout','ContextFactory', 'ProcessDataFactory', '$routeParams', 'dateFilter', '$document', '$location', '$log',
    function ($scope, $locale, $window, pickadateUtils,$timeout,ContextFactory, ProcessDataFactory, $routeParams, dateFilter, $document, $location, $log) {

        var absenceDataCount = 0;
        $scope.openLegends = false;


        $scope.checkLegends = function () {
            if($scope.openLegends) {
                $scope.openLegends = false;

            } else {
                $scope.openLegends = true;

            }
        };
        //calendar config for currentAbsences
        Date.prototype.yyyymmdd = function() {

            var yyyy = this.getFullYear().toString();
            var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
            var dd  = this.getDate().toString();

            return yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
        };
        Date.prototype.addHours = function(h) {
            this.setTime(this.getTime() + (h*60*60*1000));
            return this;
        };

        function isDateDisabled(dateClass) {
            return (/pickadate-disabled/.test(dateClass) || /pickadate-coyholiday/.test(dateClass));
        };

        $scope.allSelectedDates = [];

        $scope.parentobj = {
            clickCount : []
        };

        $scope.startDateOperation = function (dateObj, dateClass, displayMode) {
            if (isDateDisabled(dateClass)) {
                return;
            }

                var keepGoing = true;
                angular.forEach($scope.allAbsences, function (thisDate) {
                    if (keepGoing) {
                        if (thisDate.myDate === dateObj) {
                            $log.debug('Date in Absences : ' + thisDate.myDate);
                            $scope.selectedObject = thisDate.myObject;
                            keepGoing = false;
							if ($scope.processItem.data.flags && $scope.processItem.data.flags.showDetails == 'true' ) {
								$scope.viewItemInModal('absence item', thisDate.myObject.id);
							}
                        }
                    }
                });

                if (keepGoing) {
                    // alert(dateObj);
                    $scope.dateCount = $scope.allSelectedDates.length;
                    $scope.dateCounter = 0;
                    if ($scope.dateCount == 0) {
                        $scope.allSelectedDates.push(dateObj);
                        $scope.vacationDates.push(dateObj);
                        $scope.dateCounter++;
                        $scope.date = dateObj;
                        $log.debug('date 1 ' + dateObj);
                    }
                    if ($scope.dateCount == 1) {
                        $scope.allSelectedDates.push(dateObj);
                        // $scope.vacationDates = [];
                        var start = $scope.allSelectedDates[0],
                            end = $scope.allSelectedDates[1],
                            currentEndDate = new Date(end),
                            currentDate = new Date(start);
                        $log.debug("calendar config for start = " + $scope.allSelectedDates[0]);
                        while (currentDate <= currentEndDate) {
                            $log.debug('calendar date=' + new Date(currentDate).yyyymmdd());
                            $scope.vacationDates.push(new Date(currentDate).yyyymmdd());
                            $scope.date = new Date(currentDate).yyyymmdd();
                            currentDate.setDate(currentDate.getDate() + 1);

                        }

                        var params = {dataId: 'create_select_reason', startDate: start, endDate: end};
                        $scope.open(params);


                    }
                    if ($scope.dateCount == 2) {
                        $scope.allSelectedDates = [];
                        $scope.vacationDates = [];
                        $scope.allSelectedDates.push(dateObj);
                        $scope.vacationDates.push(dateObj);
                        $scope.date = dateObj;
                        $log.debug('date 1 ' + dateObj);
                    }

                }
        };

        $scope.changeYearOperation = function (offset){
            //alert(offset);
            var deferredProcData = ProcessDataFactory.query({teamMemberId: ContextFactory.teamMemberId, processId: $routeParams.processId, dataType: 'views', dataId: $scope.processItem.detailViewName, startYear: offset});

                    deferredProcData.$promise.then(function (data) {
                        if (data.trusted) {
                            data.trusted.forEach(function (field) {
                                if (data[field]) {
                                    data[field] = $sce.trustAsHtml(data[field]);
                                } else {
                                    $log.debug("Unable to find field in data: " + field);
                                }
                            });
                        }

                        absenceDataCount = 0;
                        //$scope.processItem.data = data;
                        var x = data;
                        x.absences = _.sortBy(x.absences, function(o) {
                            var dt = new Date(o.startDate);
                            return -dt;
                        });
                        $scope.processItem.data = x;
                    });
        };

        function watchProcessItemData() {
            return $scope.processItem.data;
        };

        $scope.$watch(watchProcessItemData, function (newVal, oldVal) {
            if (!newVal) {
                return;
            }

            var data = newVal;

			if (data.absences) {
				data.absences = _.sortBy(data.absences, function (o) {
					var dt = new Date(o.startDate);
					return -dt;
				});
			}

            $scope.spinner = true;
            $scope.dayoffDates = []; // Absences
            $scope.vacationDates = []; // current selection
            $scope.holidayDates = []; // Paid Time Off
            $scope.allAbsences = []; // ALL ABSENCES dates + Labels
            $scope.allCoyholidays = []; // ALL Company Holiday Dates + Labels
            $scope.coyholidayDates = []; // company holiday dates
            $scope.weekendDates = []; // weekends dates
            $scope.setMonths = 12;



            //$log.debug("absence data from processItem.data----------------------------------");
            $scope.workingDaysInStartYear = data.workingDaysInStartYear;
            $scope.workingDaysInEndYear = data.workingDaysInEndYear;
            $scope.directReports = data.directReports;



            $scope.minDate = data.yearStart;
           // $log.debug("%c $scope.workingDaysInStartYear**************************"+$scope.workingDaysInStartYear+" ", "color: green; font-size: 12px");
           // $log.debug("%c $scope.minDate**************************"+$scope.minDate+" ", "color: green; font-size: 12px");


            //calendar date formatter '2014-09-18' ie YYYY-MM-DD
            Date.prototype.yyyymmdd = function() {

                var yyyy = this.getFullYear().toString();
                var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
                var dd  = this.getDate().toString();

                return yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
            };

            //Fillup weekendDates from workingDaysInStartYear array object
            var getWorkingDaysInStartYear = getWeekEnds($scope.workingDaysInStartYear);

            //Fillup weekendDates from workingDaysInEndYear array object
            var getWorkingDaysInEndYear = getWeekEnds($scope.workingDaysInEndYear);

            $scope.weekendDates = getWorkingDaysInStartYear.weekEndsDates.concat(getWorkingDaysInEndYear.weekEndsDates);
            $scope.allCoyholidays = getWorkingDaysInStartYear.allCoyDates.concat(getWorkingDaysInEndYear.allCoyDates);
            $scope.coyholidayDates = getWorkingDaysInStartYear.coysDates.concat(getWorkingDaysInEndYear.coysDates);


            if (data.calendarItems) {
              //  $log.debug("%c data.calendarItems>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+data.calendarItems+" ", "color: green; font-size: 11px");
                var mydataAbsence = data.calendarItems;
                var allAbsencesTeamYou = [], dayoffDatesTeamYou = [], holidayDatesTeamYou = [];

                //Fillup absences - Vacation + Absence
                angular.forEach(data.calendarItems, function (myitem) {
                    var start = myitem.startDate,
                        end = myitem.endDate,
                        dcurrentEndDate = new Date(moment(end)),
                        dcurrentDate =  new Date(moment(start)),
                        currentEndDate = dcurrentEndDate,
                        currentDate = dcurrentDate;

                    // $log.debug("start ============================> "+start);
                    while (currentDate <= currentEndDate) {
                        //$log.debug('myitem.status ============================================================================================== ' + myitem.status);
                        //check weekends and remove from absences
                        if (_.indexOf($scope.weekendDates, moment(currentDate).format('YYYY-MM-DD')) >= 0) {
                            $log.debug('Weekend is there!');
                        } else if(_.indexOf($scope.coyholidayDates, moment(currentDate).format('YYYY-MM-DD')) >= 0){
                            $log.debug('Coy Holiday is there!');
                        } else {

                            allAbsencesTeamYou.push({myReason: myitem.status+' '+myitem.reason.value, myStatus: myitem.status, myObject: myitem, myDate: moment(currentDate).format('YYYY-MM-DD')});
                            if (myitem.recordTypeName == 'Vacation') {

                                dayoffDatesTeamYou.push(moment(currentDate).format('YYYY-MM-DD'));
                            }
                            if (myitem.recordTypeName == 'Absence') {

                                holidayDatesTeamYou.push(moment(currentDate).format('YYYY-MM-DD'));
                            }

                        }


                        currentDate.setDate(currentDate.getDate() + 1);
                    }
                });

               //if (_.findWhere($scope.parentobj.clickCount, {id: ContextFactory.teamMemberId}) == '')
                var checkClickCount = false;
                angular.forEach($scope.parentobj.clickCount, function(x){
                    if(x.id == ContextFactory.teamMemberId){
                        checkClickCount = true
                    }
                });

                if(!checkClickCount) {
                    $scope.parentobj.clickCount.push({id: ContextFactory.teamMemberId, loaded: false, open: false});
                }

                $scope.allAbsences = allAbsencesTeamYou;
                $scope.dayoffDates = dayoffDatesTeamYou; // Absences
                $scope.vacationDates = []; // current selection
                $scope.holidayDates = holidayDatesTeamYou; // Paid Time Off
                // $log.debug('ContextFactory.teamMember.teamMember.jobTitle-----------------------------> '+ContextFactory.teamMember.teamMember.jobTitle)
                $scope.date = new Date().yyyymmdd();

                $scope.render(new Date(dateFilter(new Date(), 'yyyy-MM-dd')));

            }


            dataReady();


        }, true);

        $scope.$watch(function(){
            return $window.innerWidth;
        }, function(value) {
            $log.debug('$scope.winWidth ===================>>>'+value);
            if(value -810 > 768){
                if($scope.currentDate) {
                    $scope.render($scope.currentDate);

                }
            }
        });

        $scope.render = function (initialDate) {
            // $log.debug('initialDate======================='+initialDate);
            initialDate = new Date(initialDate.getFullYear(), initialDate.getMonth(), 1, 3);
            // $log.debug('initialDate======================='+initialDate);
            var currentMonth = initialDate.getMonth() + 1,
                dayCount = new Date(initialDate.getFullYear(), initialDate.getMonth() + 1, 0, 3).getDate(),
                prevDates = pickadateUtils.dateRange(-initialDate.getDay(), 0, initialDate),
                currentMonthDates = pickadateUtils.dateRange(0, dayCount, initialDate);

            var lastDate = pickadateUtils.stringToDate(currentMonthDates[currentMonthDates.length - 1]),
                nextMonthDates = pickadateUtils.dateRange(1, 7 - lastDate.getDay(), lastDate),
                allDates = currentMonthDates,
                dates = [], coyDates = [],
                today = dateFilter(new Date(), 'yyyy-MM-dd');

            $scope.currentDate = pickadateUtils.stringToDate(dateFilter(initialDate, 'yyyy-MM-dd'));

            var nextMonthInitialDate = new Date(initialDate);
            nextMonthInitialDate.setMonth(currentMonth);

            var indexOf = [].indexOf || function (item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            $scope.allowPrevMonth = true;
            $scope.allowNextMonth = true;

            for (var i = 0; i < allDates.length; i++) {
                var className = "", tooltipMessage = "", myTooltipMessage = "", date = allDates[i];
                var wkd = new Date(date);

                if (dateFilter(date, 'M') !== currentMonth.toString()) {
                    className = 'pickadate-disabled';
                    //className = 'pickadate-enabled';
                } else if (indexOf.call($scope.coyholidayDates, date) >= 0) {
                    //$log.debug('dates holiday = '+date)
                    className = 'pickadate-enabled pickadate-coyholiday';
                    angular.forEach($scope.allCoyholidays, function (thisDate) {
                        if (thisDate.myDate === date) {
                            myTooltipMessage = thisDate.myLabel;
                        }
                    });
                    tooltipMessage = myTooltipMessage;
                } else if (indexOf.call($scope.weekendDates, date) >= 0)
                    className = 'pickadate-disabled pickadate-weekend';
                else {
                    className = '';
                }

                if (date === today) {
                    className += ' pickadate-today';
                }

                coyDates.push({date: date, className: className, tooltipMessage: tooltipMessage});

            }
            //return dates



            //scope.dates = dates;
            $scope.coyDates = coyDates;

        };

        $scope.changeMonth = function (offset) {
            // If the current date is January 31th, setting the month to date.getMonth() + 1
            // sets the date to March the 3rd, since the date object adds 30 days to the current
            // date. Settings the date to the 2nd day of the month is a workaround to prevent this
            // behaviour
            // scope.changeyear({offset: 2016});
            //scope.currentDate.setDate(1);
            //scope.changeyear({offset: 2016});
            var playDate = new Date($scope.currentDate);
            var thisYr = playDate.getFullYear();
            var nextYr = new Date(playDate.setMonth(playDate.getMonth() + offset)).getFullYear();

            if(thisYr == nextYr) {
                $scope.currentDate.setMonth($scope.currentDate.getMonth() + offset);
                $scope.lastMonth = $scope.currentDate.getMonth();
                $scope.setLastMonthPrev = false;
                $scope.setLastMonthNext = false;
                $scope.render($scope.currentDate);
            } else {
                if(thisYr > nextYr) {
                    $scope.lastMonth = $scope.currentDate.getMonth();
                    $scope.setLastMonthPrev = true;
                    $scope.setLastMonthNext = false;
                    $scope.changeYearOperation(nextYr);

                } else {
                    $scope.lastMonth = $scope.currentDate.getMonth();
                    $scope.setLastMonthNext = true;
                    $scope.setLastMonthPrev = false;
                    $scope.changeYearOperation( nextYr);

                }

            }

        };

        function dataReady() {
            absenceDataCount++;

            $log.debug('data ready ' + absenceDataCount);

			$scope.spinner = false;

        };

        function getWeekEnds(days){

            var weekEndsDates = [];
            var allCoyDates = [];
            var coysDates = [];

            for(var i in days){
                var key = i;
                //$log.debug('$scope.workingDaysInStartYear = '+key);
                var val = days[i];
                var wk = 0, holiday = 0, lb = '';
                for(var j in val){
                    var sub_key = j;
                    var sub_key_val = val[j];
                    if (sub_key == 'isWeekday')
                    {
                        if(sub_key_val == false)
                        {
                            wk=1;
                        }
                    }
                    if (sub_key == 'isShift')
                    {
                        if(sub_key_val == false)
                        {
                            wk = wk+1;
                        }
                    }
                    if (sub_key == 'isHoliday')
                    {
                        if(sub_key_val == true)
                        {
                            holiday = 1;
                        }
                        else holiday = 0;
                    }
                    if (sub_key == 'label')
                    {
                        if(sub_key_val != null)
                        {
                            lb = sub_key_val;
                        }
                    }
                    //$log.debug(sub_key+' = '+val[j]);
                }
                // $log.debug(wk+' = '+holiday+' = '+lb);
                if(wk==2){
                    //its weekend
                    // var newKey  = dateFilter(new Date(key.toString()), 'yyyy-MM-dd')
                    // $log.debug('$scope.weekendDates = '+ moment(key).format('YYYY-MM-DD'));
                    weekEndsDates.push(moment(key).format('YYYY-MM-DD'));
                }

                if(holiday==1){
                    //its weekend
                    // $log.debug('$scope.coyholidayDates = '+key);
                    allCoyDates.push({myLabel: lb, myDate: moment(key).format('YYYY-MM-DD')});
                    coysDates.push(moment(key).format('YYYY-MM-DD'));
                }
            }
            return {
                'weekEndsDates': weekEndsDates,
                'allCoyDates': allCoyDates,
                'coysDates': coysDates
            };
        };

    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
        .controller('CategoryCtrl', ['$scope', '$location', '$route', '$routeParams', 'UserFactory', 'ContextFactory', 'CategoryFactory','$filter', 'ViewsService', '$log',
    function ($scope, $location, $route, $routeParams, UserFactory, ContextFactory, CategoryFactory, $filter, ViewsService, $log) {

        $log.debug('loading CategoryController');

        var currentTeam;
        var currentTeamMember;

        function loadCategory(force) {
            if ($route.current.params.teamMemberId) {

                if (force || currentTeamMember != $route.current.params.teamMemberId || currentTeam != $route.current.params.teamName) {

                    $scope.categoryItems = CategoryFactory.query({teamMemberId: $route.current.params.teamMemberId, team: $route.current.params.teamName});
                    $scope.categoryItems.$promise.then(function (result) {

                        $scope.categoryItems = $filter('orderBy')(result, 'order');

                        currentTeamMember = $route.current.params.teamMemberId;
                        currentTeam = $route.current.params.teamName;

                          $scope.teamName = currentTeam;

                        return true;
                      });
                } else {
                    $log.debug("CategoryCtrl: context unchanged");
                }
            }

            ContextFactory.callWhenLoaded(function (ContextFactory) {
                $scope.teamMember = ContextFactory.teamMember;
              /*                        $scope.teamMembers = ContextFactory.getTeamMembers();*/
              $scope.subjectManagers = ContextFactory.teamMember.Managers;
              $scope.subjectDirectReports = ContextFactory.teamMember.directReports;
              $scope.subjectCrossReports = ContextFactory.teamMember.crossReports;
              $scope.subjectColleagues = ContextFactory.teamMember.colleagues;
            });
        }

        $scope.$on('$locationChangeSuccess', function(event) {
            $log.debug('Location changed, team member ' + $route.current.params.teamMemberId + ', team ' + $route.current.params.teamName);

            loadCategory();
        });

    $scope.$watch(function() {return CategoryFactory.categoriesCleared(currentTeamMember, currentTeam);}, function (newval, oldval) {
      if (newval == true && oldval == false) {
        loadCategory(true);
      }
    });

        /* check for team tab selected */
        $scope.setTeamFlag = function() {

            if ($location.path().indexOf('/team/') >= 0) {
                return true;
            } else {
              return false;
            }
        };

    $scope.selectTeamMemberView = function(teamMemberId) {
		$log.debug('CategoryCtrl: selectTeamMemberView');
      if ($routeParams.categoryId) {
        ContextFactory.setYourPath(teamMemberId, $routeParams.categoryId, $routeParams.processId);
      } else {
        if ($location.path().lastIndexOf('/') >= 0) {
          ContextFactory.setYourOtherPath(teamMemberId, $location.path().substring($location.path().lastIndexOf('/')+1));
        } else {
          $log.error('Unknown path');
        }
      }
    };

    $scope.canSwitchToTeamView = function () {
      return $routeParams.categoryId ? ViewsService.hasTeamView() : false;
      }

      $scope.canSwitchToTeamMemberView = function () {
        return ViewsService.hasTeamMemberView();
      }


    $scope.selectTeamView = function(teamMemberId) {
      ContextFactory.setYourTeamPath(teamMemberId, currentTeam ? currentTeam : 'All Reports', $routeParams.categoryId, $routeParams.processId);
      //ContextFactory.selectTeamMember(teamMemberId, true);
    };

		$scope.setYourPath = function(category) {

			$log.debug('setYourPath in CategoryCtrl');

			if ($routeParams.teamName) {
				ContextFactory.setYourTeamPath($routeParams.teamMemberId, $routeParams.teamName, category);
			} else {
				ContextFactory.setYourPath($routeParams.teamMemberId, category);
			}
		};

		$scope.setYourOtherPath = function(other) {

			$log.debug('setYourOtherPath in CategoryCtrl');

			ContextFactory.setYourOtherPath($routeParams.teamMemberId, other);
		};

		$scope.setYourPathSub = function(category, process) {

            $log.debug('setyourpathsub in CategoryCtrl');
            if (!category) {
                $log.debug('Undefined category');
                return;
            }

            var path = '';

            if ($routeParams.teamName) {
                path += '/team/' + $routeParams.teamName;
            }

            path += '/services/' + category;

            if (process) {
                path += '/processes/' + process;
            }

            if (!ContextFactory.teamMemberId) {
                var handle = ContextFactory.registerCallWhenChanged(function() {
                    ContextFactory.unregisterCallWhenChanged(handle);

                    $location.path('/teammember/' + ContextFactory.teamMemberId + path);
                });
            } else {
                $location.path('/teammember/' + ContextFactory.teamMemberId + path);
            }
        };

        loadCategory();
    }]);



/* EOF */
/**
 * Created by CarolineR on 02/07/2015.
 */

'use strict';

angular.module('fairsailWX')
    .controller('ConfirmDialogCtrl', ['$log', '$scope', '$modalInstance', 'modalParams', 'AppConstants',
        function ($log, $scope, $modalInstance, modalParams, AppConstants) {

			$scope.AppConstants = AppConstants;

			$scope.message = modalParams.message; // used in normal confirm modal
			$scope.detail = modalParams.detail; // used in normal confirm modal
            $scope.errors = modalParams.errors; // used in confirmWarning function for warning / info confirm modal

            $scope.ok = function () {
                $log.log('getting d');

                var deferred;

				if (modalParams.operationScope && modalParams.clickAction) {
					deferred = modalParams.operationScope.$eval(modalParams.clickAction);
				}

                if (deferred) {
                    deferred.promise.then(function(result) {
                        if (result.result) {
                            if (result.errors) {
								modalParams.operationScope.errors = result;
                            }

                            $modalInstance.close(true)
                        } else {
                            $scope.errors = result;
                        }
                    });
                } else {
                    $modalInstance.close(true);
                }
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        }
    ]);


/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller('EmpDetailsCtrl', ['$scope',  function ($scope) {
        $scope.hrItems = false;
        $scope.$watch('processItem.data', function (newVal, oldVal) {
            if (!newVal) {
                return;
            } else {

                var data = newVal;
                $scope.empFieldNames = [];
                $scope.empFieldNamesData = data.fieldNames;
                // $scope.empFieldNames.push('Name');
                // $scope.empFieldNames.push('Name');
                angular.forEach($scope.empFieldNamesData, function (thisfieldNames) {
                    $scope.empFieldNames.push(thisfieldNames);
                });

                $scope.empTeamMembers = data.teamMember.teamMembers;
                $scope.hrItems = true;

            }

        });
    }]);
/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller("FooterCtrl",["$scope", '$window', 'AppConstants', 'UserFactory', 'OperationOptionsFactory', '$translate', 'LocaleFactory', function ($scope, $window, AppConstants, UserFactory, OperationOptionsFactory, $translate, LocaleFactory) {
        $scope.footerViewsHtml = AppConstants.FOOTERVIEWSHTML;

        $scope.populateDropdown = function(fieldId, targetId) {

          if (!$scope.options) {
            $scope.options = {};
          }

          UserFactory.callWhenLoaded(function(teamMemberId) {
            function setLocales(res) {
              res.options.forEach(function (option) {
                if (option.value == UserFactory.teamMember.teamMember.locale) {
                  $scope.currentLanguage = option;
                }
              });

              if (targetId) {
                $scope.options[targetId] = res.options;
              } else {
                $scope.options[fieldId] = res.options;
              }
            }

            if (fieldId != 'locales' || !UserFactory.teamMember.locales) {
              var params = {teamMemberId:UserFactory.teamMemberId,
                processId: '000000000000000000',
                operationId: 'usersetup',
                fieldId: fieldId
              };

              var deferredOptions = OperationOptionsFactory.query(params);

              deferredOptions.$promise.then(setLocales);
            } else {
              setLocales(UserFactory.teamMember.locales);
            }
          });




        }

        $scope.$watch('currentLanguage', function (newval, oldval) {

            // only do something if old value was defined
            if (newval) {
                if (newval.value != UserFactory.teamMember.teamMember.locale) {

                    // post the new language
                    var operation = new LocaleFactory();
                    operation.params = {locale: newval.value};
                    operation.$save({}).then(function(result){
                        UserFactory.teamMember.teamMember.locale = newval.value;
                        $translate.use(newval.value);

                      $window.location.reload();
                    });
                }
            }
        });
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller('PrintPdfCtrl', ['$scope', function ($scope) {

        $scope.openWin = false;
        $scope.openPdfPopup = function (id, process) {
            var newWin=null;
            var url="/apex/fHCM2__"+ process.replace(/\s/g, '') +"PDF?id=" + id;
            newWin=window.open(url, 'Popup','height=500,width=600,left=100,top=100,resizable=no,scrollbars=yes,toolbar=no,status=no');
            newWin.focus();
            $scope.openWin = true;

        };
    }]);




/* EOF */
'use strict';

angular.module('fairsailWX')

    .controller('HrNoticesCtrl', ['$scope', function ($scope) {
         $scope.hrItems = false;
         $scope.$watch('hrNoticeBoardMsg', function (newVal, oldVal) {
            if (!newVal) {
                return;
            } else {

                var data = newVal;
                $scope.hrNoticeBoardMsgLocations = [];
                //$scope.hrNoticeBoardMsgPage = data.notices;
                $scope.hrNoticeBoardMsgNotice = data.notices;
                angular.forEach($scope.hrNoticeBoardMsgNotice, function (thisNotice) {
                    angular.forEach(thisNotice, function (hrNotice) {
                        $scope.hrNoticeBoardMsgLocations.push({location: hrNotice.location, text: hrNotice.text});
                    });
                });
                $scope.hrNoticeLocationGroupsHeader = _.findWhere($scope.hrNoticeBoardMsgLocations, {location: "Header"});
                $scope.hrNoticeLocationGroupsFooter = _.findWhere($scope.hrNoticeBoardMsgLocations, {location: "Footer"});
                $scope.hrItems = true;
            }


        });

    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')

    .controller('HRRequestsStatusCtrl', ['$scope', function ($scope) {
        $scope.hrItems = false;
        $scope.$watch('processItem.data', function (newVal, oldVal) {
            if (!newVal) {
                return;
            }    else {

                var data = newVal;
                $scope.employmentDetails = data.employmentDetails;
                $scope.hrRequests = data.hrRequests;
                $scope.hrRequestsHistorySalaries = data.salaries;
                $scope.hrRequestsHistoryOperations = data.operations;
                $scope.hrRequestsHistoryJobs = data.jobs;
                $scope.hrRequestsHistoryRequests = data.requests;
                $scope.hrRequestsHistoryBonuses = data.bonuses;
                $scope.hrRequestsStatusGroups = _.groupBy($scope.hrRequests, "status");
                $scope.hrItems = true;

            }


            //$scope.hrRequestsStatusGroups = _.filter($scope.hrRequests, function(hrRequests) { return hrRequests.status == "Pending" });
            // console.log('$scope.hrRequestsStatusGroups--------------------------------------------->'+$scope.hrRequestsStatusGroups)

        });

    }]);

/* EOF */
/**
 * Created by CarolineR on 26/11/2014.
 */

'use strict';

angular.module('fairsailWX')
    .controller("InternalCommsCtrl",["$scope", "$sce", function ($scope, $sce) {

        $scope.trustSrc = function(src) {
            return $sce.trustAsResourceUrl(src);
        }
    }]);
/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller("ListEmployeesCtrl", ["$scope", "ProcessDataFactory", "ContextFactory", "$routeParams", function ($scope, ProcessDataFactory, ContextFactory, $routeParams) {
    $scope.itemOpen = false;

    $scope.openList = function (id, searchItem) {

      var teamMemberId;

      var data = {
        teamMemberId: id,
        processId: $routeParams.processId,
        dataType: 'views',
        dataId: $scope.processItem.detailViewName,
        team: $routeParams.teamName
      }

      //If searchItem equals true, search for the item passed by parameter
      if (searchItem === true) {
        data["teamMemberId"] = ContextFactory.teamMemberId;
        data["itemId"] = id;
      } else {
        data["teamMemberId"] = id;
      }

      if ($scope.itemOpen == false) {
        if (!$scope.itemOpen) {

          var deferredProcData = ProcessDataFactory.query(data);

          deferredProcData.$promise.then(function (data) {
            var data = data;
            if (data && data.teamMembers) {
              $scope.empTeamMembersChild = data.teamMembers;
            } else {
              $scope.empTeamMembersChild = [];
            }
            $scope.itemOpen = true;
          });
        }
      } else {
        $scope.itemOpen = false;
      }

    };

  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller("ListItemCtrl",["$scope", "$routeParams", "ProcessDataFactory", "ContextFactory", function ($scope, $routeParams, ProcessDataFactory, ContextFactory) {
        $scope.itemOpen = false;

        $scope.$watch('itemOpen', function(newVal, oldVal) {
            if (newVal == true) {

                // fetch the supplementary data for the item
                // scope should also be able to see items on parent scope unless it is isolated
                if ($scope.itemOpen && !$scope.item.full) {
                    var teamMemberId;
                    if ($scope.teamMember && $scope.teamMember.id) {
                        teamMemberId = $scope.teamMember.id;
                    } else {
                        teamMemberId = ContextFactory.teamMemberId
                    }
					var deferredProcData = ProcessDataFactory.get({teamMemberId: teamMemberId, processId: $routeParams.processId, dataType: 'views', dataId: $scope.processItem.detailViewName, itemId: $scope.item.id});

                    deferredProcData.$promise.then(function (data) {
                        $scope.item = data;
                        $scope.item.full = true;
                    });
                }
            }
        });
     }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller("ListTeamMemberCtrl",["$scope", "$routeParams", "ProcessDataFactory", function ($scope, $routeParams, ProcessDataFactory) {

       $scope.$watch('$parent.teamMemberOpen', function() {

            if ($scope.processItem.data) {
                // fetch the supplementary data for the item
                // scope should also be able to see items on parent scope unless it is isolated
                if ($scope.$parent.teamMemberOpen && !$scope.teamMember.data) {
                    var deferredProcData = ProcessDataFactory.query({teamMemberId: $scope.teamMember.id, processId: $routeParams.processId, dataType: 'views', dataId: $scope.processItem.detailViewName});

                    deferredProcData.$promise.then(function (data) {
                       $scope.teamMember.data = data;
                    });
                }
            }
        });

    $scope.$watch('$scope.processItem.data', function (newVal, oldVal) {
      if ($scope.teamMember) {
        $scope.teamMember.data = undefined;
      }

    });

     }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller('MainCtrl', ['$scope', 'UserFactory', 'ContextFactory', '$location', '$window', function ($scope, UserFactory, ContextFactory, $location, $window) {
        UserFactory.callWhenLoaded(function (teamMemberId) {
            //alert('selecting user as context ' + JSON.stringify($location.search()));

            if ($window.teamMemberId) {
              //alert('selecting team member');
              ContextFactory.selectTeamMember($window.teamMemberId, true, true);
            } else {
              //alert('selecting current user');
              ContextFactory.selectTeamMember(teamMemberId, true, true);
            }

        });
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
.controller('MobileMenuCtrl', ['$scope', '$location', function ($scope, $location) {
        /* Make selected left menu active in mobile dropdown menu*/
      $scope.isMobileActive = function(route) {
        if ($location.path().indexOf(route) >= 0)
            return "active";
        else
            return "inactive";
    }


}])

/* EOF */
'use strict';

angular.module('fairsailWX').controller('ModalInstanceCtrl', ['$window', '$scope', '$modalInstance', 'modalParams', '$filter', 'OperationOptionsFactory', 'AppConstants', '$timeout', 'Utils', 'FileFactory', 'LoadingNotifyService', '$log', '$sce',

	function ($window, $scope, $modalInstance, modalParams, $filter, OperationOptionsFactory, AppConstants, $timeout, Utils, FileFactory, LoadingNotifyService, $log, $sce) {
		$log.debug('Constructing ModalInstanceCtrl');

		// Compatible event handler / IE8
		var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventMethodRemove = window.removeEventListener ? "removeEventListener" : "detachEvent";
		var eventer = window[eventMethod];
		var removeEventer = window[eventMethodRemove];
		var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
		var messageRemove = eventMethodRemove == "detachEvent" ? "onmessage" : "message";
		var wxRefreshOnClose = false;

		var listener = function (e) {
			//Fix - Multiple modal instances in the DOM
			if (e.data == 'wxRefreshOnClose') {
				wxRefreshOnClose = true;
			} else {
				if ($modalInstance !== undefined && (e.data == 'wxClose' || e.data == 'wxRefresh')) {
					$scope.cancelFrame();
				}
				if (e.data == 'wxRefresh') {
					modalParams.parentScope.refreshProcess();
				}
			}

		}


		// Listen to message from child window
		eventer(messageEvent, listener, false);

		if (modalParams.urlFrame) {

			setTimeout(function () {
				var element = document.getElementsByClassName("modal-dialog")[0];
				element.style.width = '80%';
			}, 0);

			$scope.titleModal = modalParams.titleModal;
			$scope.urlFrame = $sce.trustAsResourceUrl(modalParams.urlFrame);
		}

		var inProgress = false;

		$scope.busy = function () {
			return inProgress;
		}

		$scope.data = modalParams.items;

		if ($scope.data) {
			$scope.errors = {
				errors: $scope.data.errors,
				warnings: $scope.data.warnings,
				information: $scope.data.information
			};
		}


		$scope.AppConstants = AppConstants;

		$scope.teamMember = modalParams.teamMember;

		$scope.opId = modalParams.operation.id;

		$scope.operationViewUrl = modalParams.operation.url;

		$scope.itemId = modalParams.itemId;

    $scope.processId = modalParams.processId;

		$scope.allSelectedDatesFromParent = modalParams.parentScope.allSelectedDates;

		$scope.ok = function (opId) {
			function doOperation() {
				modalParams.parentScope.errors = $scope.errors; //should really be passed as method, quick fix for correct error display when editing an absence

				var res = modalParams.parentScope.doOperation(opId, $scope.data, $scope.itemId, modalParams.childId, modalParams.operation.refresh, $scope.teamMember.id, modalParams.operation.processId);

				res.promise.then(function (result) {
					$scope.errors = result;
					if ($scope.errors.result) {
						if ($scope.errors.refresh != 'continue') {
							// enable scrolling outside of modal here
							angular.element(document.getElementsByTagName("body")).removeClass("disable-scrolling");
							$modalInstance.close(true);
							if ($window.tinymce.editors && $window.tinymce.editors.length > 0) {     //remove tinymce instance if one exists
								$log.debug('tinymce editor exists ' + $window.tinymce.editors);
								$window.tinymce.remove();
								$log.debug('tinymce editor removed' + $window.tinymce.editors);
							}
						}
					}
					inProgress = false;
				}, function (error) {
					$log.debug('Failed to doOperation');
				});
			}

			if (inProgress) {
				return;
			}

			inProgress = true;

			// if there is an attachment then upload that first
			if ($scope.data.selectedFile) {
				var file = $scope.data.selectedFile;
				$log.debug("Uploading " + file.name + " : " + file.size);

				var uploader = new FileFactory();
				uploader.params = file;
				uploader.$save({"fileName": file.name, "teamMemberId": $scope.teamMember.id}).then(function (result) {
					$log.debug('Upload file result' + JSON.stringify(result));

					if (result.result) {

						if ($scope.data.attachmentSelector) {
							$scope.data[$scope.data.attachmentSelector] = result.response;
						}

						$log.debug('Attached file id = ' + result.response.attachmentId);

						// clear temp file so it doesn't get saved as part of operation data
						$scope.data.selectedFile = undefined;

						// continue with operation
						doOperation();
					} else {
						$scope.errors = result;
					}
				}, function (error) {
					$log.debug('Failed to upload file');
				});

			} else {
				doOperation();
			}

		};

		$scope.isOperationSupported = function (operationId) {
			if (!$scope.data.operations) {
				return false;
			}
			var result = false;
			angular.forEach($scope.data.operations, function (op) {
				if (op.id === operationId) {
					result = true;
				}
			});
			return result;
		};

		$scope.toDate = function (dateString) {
			$log.debug('Converting date ' + dateString);

			if (dateString) {
				var parts = dateString.match(/(\d+)/g);
				return new Date(parts[0], parts[1] - 1, parts[2]);
			} else {
				$log.debug('Date string undefined');
			}
		};

		function populateOptions(fieldId, targetId, res) {
			if (targetId) {
				$scope.options[targetId] = res.options;
			} else {
				$scope.options[fieldId] = res.options;
			}
		}

		$scope.populateDropdown = function (fieldId, targetId, dependentFieldId, dependentFieldValue) {
			if (!$scope.options) {
				$scope.options = {};
			}

			if ($scope.data && $scope.data.options && $scope.data.options[fieldId]) {
				populateOptions(fieldId, targetId, $scope.data.options[fieldId]);
			} else {
				var params = {
					teamMemberId: $scope.teamMember.id,
					processId: modalParams.operation.processId ? modalParams.operation.processId : modalParams.processId,
					operationId: modalParams.operation.id,
					itemId: modalParams.itemId,
					fieldId: fieldId,
					dependentFieldId: dependentFieldId,
					dependentFieldValue: dependentFieldValue
				};

				var deferredOptions = OperationOptionsFactory.query(params);

				deferredOptions.$promise.then(function (res) {
					if (res != null) {
						populateOptions(fieldId, targetId, res);
					}

				});

			}
		};

		$scope.cancel = function () {
			removeEventer(messageRemove, listener, false);
			// enable scrolling outside of modal here
			angular.element(document.getElementsByTagName("body")).removeClass("disable-scrolling");
			$modalInstance.dismiss('cancel');
			if ($window.tinymce.editors && $window.tinymce.editors.length > 0) {       //remove tinymce instance if one exists
				$log.debug('tinymce editor exists ' + $window.tinymce.editors);
				$window.tinymce.remove();
				$log.debug('tinymce editor removed' + $window.tinymce.editors);
			}
		};

		$scope.cancelFrame = function () {
			removeEventer(messageRemove, listener, false);
			angular.element(document.getElementsByTagName("iframe")).remove();
			
			// enable scrolling outside of modal here
			angular.element(document.getElementsByTagName("body")).removeClass("disable-scrolling");
			$modalInstance.dismiss('cancel');
			if ($window.tinymce !== undefined && $window.tinymce.editors.length > 0) {
				$window.tinymce.remove();
			}

			if (wxRefreshOnClose == true) {
				wxRefreshOnClose = false;
				modalParams.parentScope.refreshProcess();
			}

		};

		$scope.selectFile = function (elemId) {
			var elem = Utils.getElementById(elemId);
			if (elem) {
				$timeout(function () {
					elem.click();
				});
			}
		}

		$scope.cancelUpload = function (elemId) {
			$log.debug("Cancel uploading files");

			$scope.data.selectedFile = undefined;
			$scope.data.uploadTooBig = false;

			var elem = Utils.getElementById(elemId);
			if (elem && elem.files) {
				//elem.files = undefined;
				elem.value = '';
			}

		}

		$scope.refreshOperationData = function (params) {
			params.dataId = $scope.opId;

			var attachmentSelector;
			if ($scope.data && $scope.data.attachmentSelector) {
				attachmentSelector = $scope.data.attachmentSelector;
			}

			var selectedFile;
			if ($scope.data && $scope.data.selectedFile) {
				selectedFile = $scope.data.selectedFile;
			}


			var res = modalParams.parentScope.getOperationData(params, $scope.teamMember.id);

			res.$promise.then(function (result) {
				$scope.data = result;
				if (result) {
					$scope.data.attachmentSelector = attachmentSelector;
					$scope.data.selectedFile = selectedFile;
					$scope.errors = {};

					if (result.errors && result.errors.length > 0) {
						$scope.errors.errors = result.errors;
					}
					if (result.warnings && result.warnings.length > 0) {
						$scope.errors.warnings = result.warnings;
					}
					if (result.information && result.information.length > 0) {
						$scope.errors.information = result.information;
					}
				}
			});
		};

		$scope.loading = false;

		$scope.$watch(function () {
			return LoadingNotifyService.isLoading();
		}, function (newVal, oldVal) {
			if (newVal != null) {
				$scope.loading = newVal;

				$log.debug('Loading changed to ' + $scope.loading);
			}
		})

		function dateToString(date) {
			if (angular.isDate(date)) {
				return $filter('date')(date, 'yyyy-MM-dd');
			} else {
				return date;
			}
		};

		// disable scrolling outside of modal here
		angular.element(document.getElementsByTagName("body")).addClass("disable-scrolling");
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX').controller('ModalViewItemCtrl', ['$scope', '$modalInstance', 'modalParams', '$filter', 'AppConstants', '$timeout', 'Utils', '$log',
	function ($scope, $modalInstance, modalParams, $filter, AppConstants, $timeout, Utils, $log) {

		$log.debug('Constructing ModalViewItemCtrl');

		$scope.data = modalParams.items;

		$scope.AppConstants = AppConstants;

		$scope.teamMember = modalParams.teamMember;

		$scope.viewUrl = modalParams.viewUrl;

		$scope.itemId = modalParams.itemId;

		$scope.flags = modalParams.flags;

		$scope.cancel = function () {
			$modalInstance.dismiss('cancel');
		};

		$scope.isOperationSupported = function (item, operationId) {
			if (!item || !item.operations) {
				return false;
			}
			var result = false;
			angular.forEach(item.operations, function (op) {
				if (op.id === operationId) {
					result = true;
				}
			});
			return result;
		};

		$scope.hasAction = function () {
			return false;
		}

		$scope.open = function (params, operationDataItem, teamMember) {
			modalParams.parentScope.open(params, operationDataItem, teamMember ? teamMember : $scope.teamMember);

			$scope.cancel();
		}

		$scope.doOperationOnItem = function(operationId, params, item, childId, teamMemberId) {
			modalParams.parentScope.doOperationOnItem(operationId, params, item, childId, teamMemberId ? teamMemberId : $scope.teamMember.id);

			$scope.cancel();
		}
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller('NavigationCtrl', ['$scope',
        '$filter',
        'UserFactory',
        'ContextFactory',
        'CategoryFactory',
        'ActionsFactory',
        'AppConstants',
		'$window',
    '$log',
        function ($scope, $filter, UserFactory, ContextFactory, CategoryFactory, ActionsFactory, AppConstants, $window, $log) {

        $scope.AppConstants = AppConstants;

        // if the teamMemberId is not available then postpone until
        // user loaded
        UserFactory.callWhenLoaded(function(teamMemberId) {
            $log.debug('User loaded, fetching categories');

            $scope.navigationItems = CategoryFactory.query({teamMemberId:teamMemberId});
            $scope.navigationItems.$promise.then(function (result) {

                $scope.navigationItems = $filter('orderBy')(result, 'order');

            });

            $scope.teamReportsNavigationItems = CategoryFactory.query({teamMemberId:teamMemberId, team:'All Reports'});
            $scope.teamReportsNavigationItems.$promise.then(function (result) {

                $scope.teamReportsNavigationItems = $filter('orderBy')(result, 'order');

            });

        });


            $scope.$watch('navigationItems', function(newval, oldval) {
                if (newval && !newval.$promise) {
                    // get actions and calculate badges
                    var actions = ActionsFactory.query({});

                    $scope.updateYourBadges(actions);
                }
            });

            $scope.$watch('teamReportsNavigationItems', function(newval, oldval) {
                if (newval && !newval.$promise) {
                    // get actions and calculate badges
                    var actions = ActionsFactory.query({});

                    $scope.updateTeamBadges(actions);
                }
            });

            $scope.setYourPath = function(category, process) {
            $log.debug('setYourPath in NavigationCtrl');

            if (!category) {
                $log.debug('Undefined category');
                return;
            }

            ContextFactory.setYourPath(UserFactory.teamMemberId, category, process);
        };
            $scope.setYourPathSub = function(category, process) {
                $log.debug('setyourpath in NavigationCtrl');
                if (!category) {
                    $log.debug('Undefined category');
                    return;
                }

                var path = '';

                if ($routeParams.teamName) {
                    path += '/team/' + $routeParams.teamName;
                }

                path += '/categories/' + category;

                if (process) {
                    path += '/processes/' + process;
                }

                if (!ContextFactory.teamMemberId) {
                    var handle = ContextFactory.registerCallWhenChanged(function() {
                        ContextFactory.unregisterCallWhenChanged(handle);

                        $location.path('/teammember/' + ContextFactory.teamMemberId + path);
                    });
                } else {
                    $location.path('/teammember/' + ContextFactory.teamMemberId + path);
                }
            };
        $scope.setYourTeamPath = function (teamName, category, process) {
            $log.debug('setYourTeamPath in NavigationCtrl');

            if (!teamName) {
                $log.debug('Undefined teamName');
                return;
            }

            if (!category) {
                $log.debug('Undefined category');
                return;
            }

            ContextFactory.setYourTeamPath(UserFactory.teamMemberId, teamName, category, process);
        };

        $scope.$watch(function() {return ActionsFactory.isClear();}, function (newval, oldval) {
            if (newval == true && oldval == false) {
                if ($scope.navigationItems && !$scope.navigationItems.$promise) {
                    $scope.updateYourBadges(ActionsFactory.query({}));
                }
                if ($scope.teamReportsNavigationItems && !$scope.teamReportsNavigationItems.$promise) {
                    $scope.updateTeamBadges(ActionsFactory.query({}));
                }
            } else {
                $log.debug('newval = ' + newval + ', oldval = ' + oldval);
            }
        });

        function applyBadges(items, result, team) {
            if (items && items instanceof Array && result) {
                // clear existing alerts
                items.forEach(function (category) {
                    if (category.totalAlerts) {
                        category.totalAlerts = 0;
                    }
                    category.processinstances.forEach(function (instance) {
                        if (instance.alerts) {
                            instance.alerts = 0;
                        }
                    });
                });


                // iterate over the actions then find corresponding process and increment actions count
                result.forEach(function (action) {
                        items.forEach(function (category) {
                            category.processinstances.forEach(function (instance) {
                               // $log.debug('xxxxxxx process instance.length '+ instance.length);

                                if (instance.processType == action.processType && (!action.processId || action.processId == instance.id)) {
                                    if ((!team && UserFactory.teamMemberId == action.teamMemberId) || (team &&  UserFactory.teamMemberId != action.teamMemberId)) {
                                        if (instance.alerts) {
                                            instance.alerts++;
                                        } else {
                                            instance.alerts = 1;
                                        }

                                        if (category.totalAlerts) {
                                            //$log.debug('xxxxxxx process instance.length '+ category.totalAlerts);
                                            category.totalAlerts++;
                                        } else {
                                            category.totalAlerts = 1;
                                        }
                                    }
                                }
                            });
                        });
                });
            }
        }

        $scope.setYourOtherPath = function (page) {
            $log.debug('setYourOtherPath in NavigationCtrl');

            if (!page) {
                $log.debug('Undefined page');
                return;
            }

            ContextFactory.setYourOtherPath(UserFactory.teamMemberId, page);
        };

            $scope.updateYourBadges = function (actions) {
                $log.debug('Update your badges');

                actions.$promise.then(function (result) {
                    applyBadges($scope.navigationItems, result, false);
                },function(error){
                    //$log.debug('Errorrrrrrrr');
                },function(percentComplete){
                });

            };
            $scope.openSubMenu = false;


            $scope.openMenuUl = function () {
                if($scope.openSubMenu) {
                    $scope.openSubMenu = false;

                } else {
                    $scope.openSubMenu = true;

                }
            };
            $scope.updateTeamBadges = function (actions) {
                $log.debug('Update team badges');

                actions.$promise.then(function (result) {
                    applyBadges($scope.teamReportsNavigationItems, result, true);
                },function(error){
                    //$log.debug('Errorrrrrrrr');
                },function(percentComplete){
                });

            };

			$scope.showSearch = $window.showSearch != false;

          $scope.logoutsf = function() {
            var sfAccManagerPlugin = cordova.require("com.salesforce.plugin.sfaccountmanager");
            sfAccManagerPlugin.logout();
          }
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller('OrgChartPrintCtrl', ['$scope', '$modal', 'OrgChartFactory', '$routeParams', 'ContextFactory', 'Utils', '$log', '$translate', '$rootScope', function ($scope, $modal, OrgChartFactory, $routeParams, ContextFactory, Utils, $log, $translate, $rootScope) {
        $scope.getLevels = false;
        $scope.getLevel = false;
        $scope.masterDRLoadStatus = [];
        $scope.masterDR = [];
        $scope.showPrintBtn = false;

        function buildSelectOptions() {
            $translate('fHCM2__Action_Select_Level').then(function (translation) {
                $scope.orgChartLevel.value.label = translation;
                $scope.orgChartLevel.levels[0].label = translation;
            });
            $translate('fHCM2__Action_3_Levels').then(function (translation) {
                $scope.orgChartLevel.levels[1].label = translation;
            });
            $translate('fHCM2__Action_4_Levels').then(function (translation) {
                $scope.orgChartLevel.levels[2].label = translation;
            });
            $translate('fHCM2__Action_5_Levels').then(function (translation) {
                $scope.orgChartLevel.levels[3].label = translation;
            });
            $translate('fHCM2__Action_All_Levels').then(function (translation) {
                $scope.orgChartLevel.levels[4].label = translation;
            });

        }

        $rootScope.$on('$translateChangeSuccess', function () { /* get translations to populate labels in orgChartLevel*/
            buildSelectOptions();
        });

        $rootScope.$on('$locationChangeSuccess', function () { /* refresh translations if selecting new subject for org chart */
            $translate.refresh();
        });


        buildSelectOptions();

        $scope.orgChartLevel = {
            "value": {"id": 1, "label": ''}, /* default value for select element */
            "levels": [ {"id": 1, "label": ''}, {"id": 2, "label":''}, {"id": 3, "label":''}, {"id": 4, "label": ''}, {"id": 5, "label": ''}] /* possible select options */
        };

        if($scope.orgChartLevel.value.id != 1){
            $scope.showPrintBtn = true;
        }
        // $scope.orgChartLevel = ['Select chart level to print','1','2'];



        function getDirectReportCount(arrayLength) {
            arrayLength = Math.ceil(arrayLength);
            var arr = new Array(arrayLength), i = 0;
            for (; i < arrayLength; i++) {
                arr[i] = i;
            }
            return arr;
        };

        var getlevelsInt = function(orgChartLevel){
            var levelsDownward = 0;
            switch(orgChartLevel.value.id){
                case 2:
                    levelsDownward = 3;
                    break;
                case 3:
                    levelsDownward = 4;
                    break;
                case 4:
                    levelsDownward = 5;
                    break;
                case 5:
                    levelsDownward = -1;
                    break;
                default:
                    levelsDownward = 3;
                    break;
            }
            $log.debug('levels downward is ' +levelsDownward);
            return levelsDownward;
        };

        function getOrgChart() {
            //var deferred = OrgChartFactory.get({teamMemberId: $routeParams.teamMemberId, level: '3'});

            /* get levels below the subject, not including the subject */
            var deferred = OrgChartFactory.get({teamMemberId: $routeParams.teamMemberId, level: getlevelsInt($scope.orgChartLevel)});
            deferred.$promise.then(function (result) {
                //  sort here

                $scope.chartLayout = [];
                $scope.directReportChartLayOutChildren = [];


                $log.debug('org chart result is ' +JSON.stringify(result));

                /* var reports = result.person.directReports.concat(result.person.crossReports);*/
                $scope.subject = result.person;
                $scope.directReportRowsCharts  =  result.person.directReports;
                $scope.directReportRowChartsLength = $scope.directReportRowsCharts.length;
                var rowsChartsSplice  =  result.person.directReports;
                $scope.directReportCount = getDirectReportCount(Math.ceil($scope.directReportRowsCharts.length/10));

                $scope.getDrCount = 0;
                angular.forEach($scope.directReportRowsCharts, function(thisGroup){
                    if(thisGroup.directReports && thisGroup.directReports.length > 0){
                        $scope.getDrCount = $scope.getDrCount + 1;
                    }
                });

                var z, i, x = 0;
                var y = 0;

                angular.forEach($scope.directReportCount, function(thisDirectReportCount){
                    //console.log('inside directReportRowsChartsSplice^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'+$scope.directReportRowsCharts.length)
                    var group = rowsChartsSplice.slice(y, 10 + y);
                    var count = 0;
                    angular.forEach(group, function(thisGroup){
                        if(thisGroup.directReports){
                            if(thisGroup.directReports.length > count){
                                count = thisGroup.directReports.length;
                            }
                        }
                    });
                    $scope.chartLayout.push({rowId: x, rowCount: group.length, maxDirectReportCount: count});
                    x = x + 1;
                    y = y + 10;
                });

            }).then(function(){

                    if($scope.subject.directReports.length > 0){

                    getPrintableOgrChart_N_Levels($scope.subject.directReports);
                }

                if( $scope.orgChartLevelContentArray.length == counter){
                    $scope.showPrintBtn = true;
                }

            });
        }


        var counter = 0;
        var getPrintableOgrChart_N_Levels = function(directReportsList){
            $scope.showPrintBtn = false;
            //level--;
            $scope.chartLayoutDirectReport = [];

            if (directReportsList.length > 0) {

                angular.forEach(directReportsList, function (directReport) {
                    counter++;
                    var orgChartLevelContent = {
                        "primaryManager": null,
                        "person": {
                            person: directReport.person,
                            orgChartDetails: directReport.orgChartDetails
                        },
                        "directReports": [],
                        "maxDirectReportCount": 0,
                        "rowCount": [0]
                    };


                    if(directReport.directReports != null ) {
                        if (directReport.directReports.length > 0) {
                            angular.forEach(directReport.directReports, function (directReportsDirectReport) {
                                orgChartLevelContent.directReports.push({
                                    person: directReportsDirectReport.person,
                                    orgChartDetails: directReportsDirectReport.orgChartDetails,
                                    directReports: directReportsDirectReport.directReports
                                });


                                if (directReportsDirectReport.directReports != null) {
                                    if (orgChartLevelContent.maxDirectReportCount < Math.ceil(directReportsDirectReport.directReports.length)) {
                                        orgChartLevelContent.maxDirectReportCount = Math.ceil(directReportsDirectReport.directReports.length);
                                    }
                                }


                            });
                        }
                    }

                    orgChartLevelContent.rowCount = getDirectReportCount(Math.ceil(orgChartLevelContent.directReports.length / 10));

                    $scope.orgChartLevelContentArray.push(orgChartLevelContent);

                    getPrintableOgrChart_N_Levels(orgChartLevelContent.directReports);

                });
            }
        };



        $scope.$watch(function(){return $scope.orgChartLevel.value.id;}, function (newVal, oldVal) {

            if(newVal != 1){
                $scope.levels = getlevelsInt($scope.orgChartLevel);

                $scope.orgChartLevelContentArray = [];
                counter = 0;
                //get orgchart details from the server
                $scope.showPrintBtn = false;
                getOrgChart();                                    // run and populate data
            } else {
                $scope.showPrintBtn = false;
            }

        });

        $scope.openLookupPopup = function (orderBy) {
            $scope.openWin = false;
            var newWin=null;
            var url="/apex/fHCM2__OrgChartPDF?id=" + $routeParams.teamMemberId + "&orderBy=" + orderBy;
            newWin=window.open(url, 'Popup','height=500,width=600,left=100,top=100,resizable=no,scrollbars=yes,toolbar=no,status=no');
            newWin.focus();
            $scope.openWin = true;
        };

        $scope.setSubject = function (teamMemberId) {
            ContextFactory.setYourOtherPath(teamMemberId, 'orgchart');
        };

    }]);


/* EOF */
'use strict';

angular.module('fairsailWX').controller('PaginationCtrl', ["$scope", "$log", "$routeParams", "ProcessDataFactory", "ContextFactory", function ($scope, $log, $routeParams, ProcessDataFactory, ContextFactory) {

  $scope.page = 1;
  $scope.numPages = 0;
  $scope.searchString = '';
  $scope.oldSearchString = '';
  $scope.actualPage = 1;

  $scope.inProgress = false;

  $scope.search = function (action) {

    //Already in progress?
    if ($scope.inProgress == false) {

      $scope.inProgress = true;

      var teamMemberId;

      if ($scope.teamMember && $scope.teamMember.id) {
        teamMemberId = $scope.teamMember.id;
      } else {
        teamMemberId = ContextFactory.teamMemberId
      }

      var props = {
        teamMemberId: teamMemberId,
        processId: $routeParams.processId,
        dataType: 'views',
        dataId: $scope.processItem.detailViewName
      };


      //Any Action? First, Last, Next, Previous
      switch (action) {
        case 'first':
          $scope.page = 1;
          break;
        case 'last':
          $scope.page = $scope.numPages;
          break;
        case 'next':
          if ($scope.page < $scope.numPages) {
            $scope.page = $scope.page + 1;
          }
          break;
        case 'previous':
          if ($scope.page <= $scope.numPages) {
            $scope.page = $scope.page - 1;
          }
          break;
        default:
          $scope.page = 1;
      }

      //Search string provide?

      props['searchString'] = $scope.searchString;


      if ($scope.page <= 0 || $scope.page > $scope.numPages) {
          $scope.page = 1;
      }

      if (($scope.searchString != $scope.oldSearchString)) {
        $scope.page = 1;
      }

      props['page'] = $scope.page;

      var deferredProcData = ProcessDataFactory.get(props);

      deferredProcData.$promise.then(function (data) {
        $scope.processItem.data = data;
        $scope.inProgress = false;
      });
    }
  }

  $scope.onKeyUpEvent = function (event) {
    if (event.keyCode == 13 && !event.altKey) {
      $scope.search('search');
    }
  }

  $scope.clear = function(){
    $scope.searchString = '';
  }


  $scope.$watch('processItem.data', function (newVal, oldVal) {
    if (!newVal) {
      return;
    } else {
      var data = newVal;
      $scope.numPages = data.numPages;
      $scope.actualPage = $scope.page;
      $scope.oldSearchString = $scope.searchString;
    }

  });

  $scope.$watch('searchString', function (newVal, oldVal) {
    if (!newVal) {
      return;
    } else {
      $scope.oldSearchString = oldVal;
      $scope.page = 1;
    }
  });

}]);


/* EOF */
'use strict';

angular.module('fairsailWX')
.controller('ProcessDetailsTabCtrl', ['$scope', function ($scope) {
    this.tab = $scope.openTab ? $scope.openTab : 1;

        this.isSet = function(checkTab) {
            return this.tab === checkTab;
        };

        this.setTab = function(setTab) {
			$scope.tab.tab = setTab;
        };

		$scope.$watch('openTab', function (newVal) {
			if (newVal) {
				$scope.setTab(newVal);
			}
		});

    $scope.isSet = this.isSet;
    $scope.setTab = this.setTab;

    $scope.tab = this;
}])



/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller('SearchContactsCtrl', ['$scope', 'ContactFactory', 'UserFactory', 'ContextFactory','AppConstants', '$log', function ($scope, ContactFactory, UserFactory, ContextFactory, AppConstants, $log) {
        $scope.searchDone = false;
        $scope.contactViewsHtml = AppConstants.CONTACTVIEWSHTML;
        $scope.closeResults = false;

        $scope.remoteUrlRequestFn = function(str) {
            return {q: str};
        };

        $scope.search = function() {
            $scope.closeResults = false;
            if ($scope.searchString) {
                if ($scope.searchString != $scope.searchedTerm) {
                    $scope.searchedTerm = $scope.searchString;

                    $scope.searchContactResults = ContactFactory.query({search: $scope.searchString, group: ''});
                    $scope.searchContactResults.$promise.then(function (result) {
                        $scope.searchContactResults = result;
                        $scope.searchDone = true;
						$scope.tooManyResults = result.length >= AppConstants.MAXCONTACTSEARCHRESULTS;
                    }, function (error) {
                        $log.error("Search failed: " + error.message);
                        $scope.searchContactResults = [];
                        $scope.searchDone = true;
						$scope.tooManyResults = false;
                    });
                }
            } else {
                $scope.searchDone=false;
                $scope.searchedTerm = undefined;
            }
        }

        $scope.selectTeamMember = function(teamMemberId) {
            ContextFactory.selectTeamMember(teamMemberId, true);
        }

        $scope.onKeyUp = function (event) {
            if (event.keyCode == 13 && !event.altKey) {
                $scope.search();
            }
        }

        $scope.closeSearchResults = function () {
            $scope.closeResults = true;
            $scope.searchString = "";
			$scope.tooManyResults = false;
        }

        $scope.openOrgChart = function (teamMemberId) {
            ContextFactory.setYourOtherPath(teamMemberId, 'orgchart');
        };

		$scope.openActions = function (teamMemberId) {
			ContextFactory.setYourOtherPath(teamMemberId, 'actions');
		};

		$scope.viewerIsManager = function () {
			return UserFactory.isManager();
		}

	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller('SearchCtrl', ['$rootScope', '$scope', 'SearchFactory', 'UserFactory', 'SearchOptionsFactory', 'ContextFactory', '$translate', '$log', function ($rootScope, $scope, SearchFactory, UserFactory, SearchOptionsFactory, ContextFactory,  $translate, $log) {

		$scope.options = {};

		function search() {
			if (!$scope.criteria || $scope.criteria.skills.length == 0) {
				$log.debug('nothing to search for');

				$scope.results = undefined;

				return;
			}

			var operation = new SearchFactory($scope.criteria);
			operation.$save({
				teamMemberId: UserFactory.teamMemberId
			}).then(function (result) {
				$scope.results = result;
        $scope.criteria.skills = result.criteria;
			});
		};

		$scope.addCriteria = function () {
			if (!$scope.criteria) {
				$scope.criteria = {skills:[]};
			}

			if (!$scope.name) {
				$log.error('skill not selected');
				return;
			}

			$scope.criteria.skills.push({id:$scope.name.value, name:$scope.name.name, area:$scope.area.name});

			search();

			$scope.options['name'] = removeOptions($scope.options['name']);
			$scope.name = {value: ''}; //reset value so next search not allowed until area and name entered
		};

		$scope.deleteCriteria = function (id) {
			var skills = [];
			angular.forEach($scope.criteria.skills, function (skill) {
				if (skill.id != id) {
					skills.push(skill);
				} else {
					if ($scope.area && $scope.area.value == skill.area && $scope.options['name'] !=  undefined) {
						$scope.options['name'].push({name: skill.name, value: skill.id});
					}
				}
			});

			$scope.criteria.skills = skills;

			search();


		};

		function removeOptions(opts) {
			var options = [];
			if ($scope.criteria && $scope.criteria.skills) {
				angular.forEach(opts, function (option) {
					var matched = false;
					angular.forEach($scope.criteria.skills, function (skill) {
						if (skill.id == option.value) {
							matched = true;
						}
					});
					if (!matched) {
						options.push(option);
					}
				});
			} else {
				options = opts;
			}

			return options;
		}

		$scope.populateDropdown = function (fieldName, targetId, dependentFieldId, dependentFieldValue) {
			UserFactory.callWhenLoaded(function (teamMemberId) {
				var params = {
					teamMemberId: teamMemberId,
					fieldName: fieldName,
					dependentFieldId: dependentFieldId,
					dependentFieldValue: dependentFieldValue
				};

				var deferredOptions = SearchOptionsFactory.get(params);

				deferredOptions.$promise.then(function (res) {
					if (res) {
						// limit the options based on current critieria
						var options = removeOptions(res.options);

						if (targetId) {
							$scope.options[targetId] = options;
						} else {
							$scope.options[fieldName] = options;
						}
					}
				});
			});
		};

    $scope.showSkillsProcess = function (teamMemberId, serviceId, processId) {

      if (!(teamMemberId && serviceId && processId)) {
        $log.debug('Undefined TM id or service id or process id');
        return;
      }
      ContextFactory.setYourPath(teamMemberId, serviceId, processId);
    };



    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('ServiceBarCtrl', ['$scope', '$location', '$route', '$routeParams', 'UserFactory', 'ContextFactory', 'CategoryFactory','$filter', 'ViewsService', '$log',
		function ($scope, $location, $route, $routeParams, UserFactory, ContextFactory, CategoryFactory, $filter, ViewsService, $log) {

			$log.debug('loading ServiceBarCtrl');

			var currentTeam;
			var currentTeamMember;

			function loadCategory(force) {
				if ($route.current && $route.current.params.teamMemberId) {

					if (force || currentTeamMember != $route.current.params.teamMemberId || currentTeam != $route.current.params.teamName) {

						$scope.categoryItems = CategoryFactory.query({teamMemberId: $route.current.params.teamMemberId, team: $route.current.params.teamName});
						$scope.categoryItems.$promise.then(function (result) {

							$scope.categoryItems = $filter('orderBy')(result, 'order');

							currentTeamMember = $route.current.params.teamMemberId;
							currentTeam = $route.current.params.teamName;

							$scope.teamName = currentTeam;

							return true;
						});
					} else {
						$log.debug("ServiceBarCtrl: context unchanged");
					}
				}

				ContextFactory.callWhenLoaded(function (ContextFactory) {
					$scope.teamMember = ContextFactory.teamMember;
					/*                        $scope.teamMembers = ContextFactory.getTeamMembers();*/
					$scope.subjectManagers = ContextFactory.teamMember.Managers;
					$scope.subjectDirectReports = ContextFactory.teamMember.directReports;
					$scope.subjectCrossReports = ContextFactory.teamMember.crossReports;
					$scope.subjectColleagues = ContextFactory.teamMember.colleagues;
				});
			}

			$scope.$on('$locationChangeSuccess', function(event) {
				$log.debug('Location changed, team member ' + $route.current.params.teamMemberId + ', team ' + $route.current.params.teamName);

				loadCategory();
			});

			$scope.$watch(function() {return CategoryFactory.categoriesCleared(currentTeamMember, currentTeam);}, function (newval, oldval) {
				if (newval == true && oldval == false) {
					loadCategory(true);
				}
			});

			/* check for team tab selected */
			$scope.setTeamFlag = function() {

				if ($location.path().indexOf('/team/') >= 0) {
					return true;
				} else {
					return false;
				}
			};

			$scope.selectTeamMemberView = function(teamMemberId) {
				if ($routeParams.categoryId) {
					ContextFactory.setYourPath(teamMemberId, $routeParams.categoryId, $routeParams.processId);
				} else {
					if ($location.path().lastIndexOf('/') >= 0) {
						ContextFactory.setYourOtherPath(teamMemberId, $location.path().substring($location.path().lastIndexOf('/')+1));
					} else {
						$log.error('Unknown path');
					}
				}
			};

			$scope.canSwitchToTeamView = function () {
				return $routeParams.categoryId ? ViewsService.hasTeamView() : false;
			}

			$scope.canSwitchToTeamMemberView = function () {
				return ViewsService.hasTeamMemberView();
			}


			$scope.selectTeamView = function(teamMemberId) {
				ContextFactory.setYourTeamPath(teamMemberId, currentTeam ? currentTeam : 'All Reports', $routeParams.categoryId, $routeParams.processId);
				//ContextFactory.selectTeamMember(teamMemberId, true);
			};

			$scope.setYourPath = function(category) {

				$log.debug('setYourPath in ServiceBarCtrl');

				if ($routeParams.teamName) {
					ContextFactory.setYourTeamPath($routeParams.teamMemberId, $routeParams.teamName, category);
				} else {
					ContextFactory.setYourPath($routeParams.teamMemberId, category);
				}
			};

			$scope.setYourOtherPath = function(other) {

				$log.debug('setYourOtherPath in ServiceBarCtrl');

				ContextFactory.setYourOtherPath($routeParams.teamMemberId, other);
			};

			$scope.setYourPathSub = function(category, process) {

				$log.debug('setyourpathsub in ServiceBarCtrl');
				if (!category) {
					$log.debug('Undefined category');
					return;
				}

				var path = '';

				if ($routeParams.teamName) {
					path += '/team/' + $routeParams.teamName;
				}

				path += '/services/' + category;

				if (process) {
					path += '/processes/' + process;
				}

				if (!ContextFactory.teamMemberId) {
					var handle = ContextFactory.registerCallWhenChanged(function() {
						ContextFactory.unregisterCallWhenChanged(handle);

						$location.path('/teammember/' + ContextFactory.teamMemberId + path);
					});
				} else {
					$location.path('/teammember/' + ContextFactory.teamMemberId + path);
				}
			};

			loadCategory();
		}]);



/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('ShowCategoryCtrl',
	['$scope',
		'$routeParams',
		'$sce',
		'$location',
		'HrNoticeCategoryFactory',
		'ContextFactory',
		'CategoryFactory',
		'ProcessFactory',
		'ProcessDataFactory',
		'Utils',
		'ActionsFactory',
		'ViewsService',
		'$log',
		function ($scope, $routeParams, $sce, $location, HrNoticeCategoryFactory, ContextFactory, CategoryFactory, ProcessFactory, ProcessDataFactory, Utils, ActionsFactory, ViewsService, $log) {
			// save the current category id on the scope so it can be
			// referred to in urls for process details
			$scope.categoryId = $routeParams.categoryId;

			ViewsService.hasTeamView(true);
			ViewsService.hasTeamMemberView(false);

			function finishedLoading(processItems) {
				$scope.numberOfColumnsAvailable = Utils.getNumberOfColumnsAvailable($scope.displayMode);
				$scope.rows = Utils.sortTilesIntoColumns(processItems, $scope.displayMode);
				inProgress = false;
				$scope.updateBadges(ActionsFactory.query({}));
			}

			var inProgress = false;
			function getProcesses() {
				if (inProgress) {
					//$log.debug('refresh already in progress');
					return;
				} else {
					inProgress = true;
				}

				$scope.rows = [];
				$scope.numberOfColumnsAvailable = 0;

				$log.debug('Get Hrnotices for category');

				$scope.hrNoticeBoard = HrNoticeCategoryFactory.get({teamMemberId: ContextFactory.teamMemberId, categoryId: $routeParams.categoryId});
				$scope.hrNoticeBoard.$promise.then(function (myres) {
					// store the hrNoticeBoard or get the details
					$scope.hrNoticeBoardMsg = myres;
					// $scope.hrNoticeBoardMsgPage = myres.myPage;
					// $scope.hrNoticeBoardMsgNotice = myres.listNotice;
					$log.debug ('$scope.hrNoticeBoardMsgNotice from categories called---------------------------------------------------->'+$scope.hrNoticeBoardMsgNotice)

				});


				$log.debug('Get processes for category');

				// loop over all the processes in a category
				var deferredCat = CategoryFactory.get({teamMemberId: ContextFactory.teamMemberId, categoryId: $routeParams.categoryId, team: $routeParams.teamName});

				deferredCat.$promise.then(function (category) {

					if (!category || !category.processinstances || category.processinstances.length == 0) {
						ViewsService.hasTeamView(false);
						ViewsService.hasTeamMemberView(false);
						$scope.unavailable = true;
						return;
					}

					$log.debug('hasteamview ' + category.hasTeamView);
					ViewsService.hasTeamView(category.hasTeamView ? true : false);
					ViewsService.hasTeamMemberView(category.hasTeamMemberView ? true : false);

					/*
					 Load all the processes before adding them to the scope
					 so that the correct ordering can be applied
					 */
					var processItems = [];
					var processItemCounter = 0;

					category.processinstances.forEach(function (process) {
						function handleProcessData(data, currentIndex) {
							if (data) {
								if (data.trusted) {
									data.trusted.forEach(function (field) {
										if (data[field]) {
											data[field] = $sce.trustAsHtml(data[field]);
										} else {
											$log.debug("Unable to find field in data: " + field);
										}
									});
								}

								processItems[currentIndex].data = data;
							} else {
								processItems[currentIndex].data = [];
							}
						}

						function handleProcessDetail(res) {
							var currentIndex = processItems.length;
							processItems[currentIndex] = res;
							processItemCounter--;

							// get the tiles
							var tile = Utils.selectTile(res.preferredNumberOfColumns, Utils.getNumberOfColumnsAvailable($scope.displayMode), res.tileviews);

							processItems[currentIndex].tileView = tile.url;
							processItems[currentIndex].numberOfColumns = tile.numberOfColumns;

							if (res.data) {
								var data = JSON.parse(res.data);
								handleProcessData(data, currentIndex);
							} else {

							// get process data
							var deferredProcData = ProcessDataFactory.query({teamMemberId: ContextFactory.teamMemberId, processId: process.id, dataType:'views', dataId: tile.name, team: $routeParams.teamName});

							deferredProcData.$promise.then(function (data) {
								handleProcessData(data, currentIndex);
							});
						}

							if (processItemCounter == 0) {
								finishedLoading(processItems);
							}
						}

						processItemCounter++;

						if (process.detail) {
							handleProcessDetail(process.detail);
						} else {
							var deferredProc = ProcessFactory.get({teamMemberId: ContextFactory.teamMemberId, processId: process.id, team: $routeParams.teamName});

							deferredProc.$promise.then(function (res) {
								handleProcessDetail(res);

							}, function (error) {
								$log.debug(error);

								processItemCounter--;

								if (processItemCounter == 0) {
									finishedLoading(processItems);
								}
							});
						}
					});

				});
			}

			$scope.getColumnStyle = function(numberOfColumnsForTile, numberOfColumnsAvailable) {
				if (!numberOfColumnsForTile || numberOfColumnsForTile < 2 ) {
					if (numberOfColumnsAvailable <= 3) {
						return 'col-sm-6 col-md-4 col-lg-4';    // laptop using col-lg style, ie. 3 cols available
					} else {
						return 'col-sm-6 col-md-4 col-lg-3';    //desktop using col-lg style, ie. 4 cols available
					}
				}
				if (numberOfColumnsForTile == 2) {
					if ($scope.displayMode == 'desktop') {
						return 'col-lg-6';
					}
					else if ($scope.displayMode == 'laptop') {
						return 'col-lg-8';
					}
					else {
						return 'col-sm-12 col-md-8';
					}
				}
				if (numberOfColumnsForTile == 3) {
					if ($scope.displayMode == 'desktop') {
						return 'col-lg-9';
					}
					else if ($scope.displayMode == 'laptop') {
						return 'col-lg-12';
					}
					else {
						return 'col-sm-12 col-md-12';
					}
				}
				else {
					return 'col-lg-12';
				}
			};


			$scope.displayMode = ''; // default value

			$scope.$watch('displayMode', function(value) {
				$log.debug('display mode update');
				var refresh = true;
				switch(value) {
					case 'mobile':
						// do stuff for mobile mode
						$log.debug('mobile');
						break;
					case 'tablet':
						// do stuff for tablet mode
						// and so on
						break;
					case 'tablet-landscape':
						// do stuff for -landscape mode
						// and so on
						break;
					case 'laptop':
						// do stuff for laptop mode
						// and so on
						break;
					case 'desktop':
						// do stuff for desktop mode
						// and so on
						break;
					default:
						refresh = false;
						break;
				}

				if (refresh) {
					//$log.debug('refreshing for display mode change');
					getProcessesWhenContextLoaded();
				};
			});


			function getProcessesWhenContextLoaded() {
				ContextFactory.callWhenLoaded(function (context) {
					//$log.debug('context loaded');
					getProcesses();
				});
			}

			$scope.$watch(function() {return ActionsFactory.isClear();}, function (newval, oldval) {
				if ($scope.rows && !$scope.rows) {
					$scope.updateBadges(ActionsFactory.query({}));
				}
			});

			$scope.updateBadges = function (actions) {
				$log.debug('Updating badges');
				actions.$promise.then(function (result) {
					if ($scope.rows && $scope.rows instanceof Array && result) {
						// clear existing alerts
						$scope.rows.forEach(function (row) {
							row.forEach(function (instance) {
								if (instance.alerts) {
									instance.alerts = 0;
								}
							});
						});


						// iterate over the actions then find corresponding process and increment actions count
						var team = $routeParams.teamName ? true : false;
						result.forEach(function (action) {
							$scope.rows.forEach(function (row) {
								row.forEach(function (instance) {

									if (instance.processType == action.processType && (!action.processId || action.processId == instance.id)) {
										if ((!team && ContextFactory.teamMemberId == action.teamMemberId) || (team &&  ContextFactory.teamMemberId != action.teamMemberId)) {
											$log.debug('adding alert for process ' + instance.label);
											if (instance.alerts) {
												instance.alerts++;
											} else {
												instance.alerts = 1;
											}
										}
									}
								});
							});
						});
					}
				});
			};

			$scope.showProcessDetail = function(category, process) {

				$log.debug('setyourpath in ShowCategoryCtrl');
				if (!category) {
					$log.debug('Undefined category');
					return;
				}

				var path = '';

				if ($routeParams.teamName) {
					path += '/team/' + $routeParams.teamName;
				}

				path += '/services/' + category;

				if (process) {
					path += '/processes/' + process;
				}

				if (!ContextFactory.teamMemberId) {
					var handle = ContextFactory.registerCallWhenChanged(function() {
						ContextFactory.unregisterCallWhenChanged(handle);

						$location.path('/teammember/' + ContextFactory.teamMemberId + path);
					});
				} else {
					$location.path('/teammember/' + ContextFactory.teamMemberId + path);
				}
			};
		}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('ShowProcessCtrl', ['$scope', '$window', '$sce', '$document', '$routeParams', '$modal', '$q', '$timeout', 'HrNoticeFactory', 'UserFactory', 'ContextFactory', 'CategoryFactory', 'ProcessFactory', 'ProcessDataFactory', 'ActionsFactory', 'AppConstants', 'ViewsService', '$log',
		function ($scope, $window, $sce, $document, $routeParams, $modal, $q, $timeout, HrNoticeFactory, UserFactory, ContextFactory, CategoryFactory, ProcessFactory, ProcessDataFactory, ActionsFactory, AppConstants, ViewsService, $log) {

			var operationModalOpen = false;
			var itemModalOpen = false;

			$scope.teamMember = ContextFactory.teamMember;

			function confirmWarning(errors) {
				$modal.open({
					templateUrl: AppConstants.CONFIRMWARNINGVIEWSHTML,
					backdrop: 'static',
					controller: 'ConfirmDialogCtrl',
					resolve: {
						modalParams: function () {
							return {
								errors: errors,
								operationScope: $scope.$parent
							};
						}
					}
				});
			}

			function openModalWithData(params, operation, data, teamMember) {

				var modalInstance = $modal.open({
					templateUrl: AppConstants.MODALVIEWSHTML,
					// templateUrl: operation.url,
					controller: 'ModalInstanceCtrl',
					backdrop: 'static',
					resolve: {
						modalParams: function () {
							return {
								teamMember: teamMember ? teamMember : ContextFactory.teamMember.teamMember,
								itemId: params.itemId,
								processId: $routeParams.processId,
								childId: params.childId,
								items: data,
								operation: operation,
								parentScope: $scope
							};
						}
					}
				});

				modalInstance.result.then(function (result) {
					$log.debug('modal closed');

					operationModalOpen = false;
				}, function () {
					operationModalOpen = false;
				});
			}

			function handleProcessData(data) {
				if (data) {
					if (data.trusted) {
						data.trusted.forEach(function (field) {
							if (data[field]) {
								data[field] = $sce.trustAsHtml(data[field]);
							} else {
								$log.debug("Unable to find field in data: " + field);
							}
						});
					}

					$scope.processItem.data = data;
				} else {
					$log.debug("No data returned for process");
				}
			}

			$scope.refreshProcess = function () {
				ViewsService.hasTeamView(false);
				ViewsService.hasTeamMemberView(false);

				/*                $window.location.reload();*/

				$scope.hrNoticeBoard = HrNoticeFactory.get({
					teamMemberId: ContextFactory.teamMemberId,
					processId: $routeParams.processId
				});
				$scope.hrNoticeBoard.$promise.then(function (myres) {
					// store the hrNoticeBoard or get the details
					$scope.hrNoticeBoardMsg = myres;
					// $scope.hrNoticeBoardMsgPage = myres.myPage;
					// $scope.hrNoticeBoardMsgNotice = myres.listNotice;
					$log.debug('$scope.hrNoticeBoardMsg Processes called---------------------------------------------------->' + $scope.hrNoticeBoardMsg)
				});

				$scope.processItem = ProcessFactory.get({
					teamMemberId: ContextFactory.teamMemberId,
					processId: $routeParams.processId,
					team: $routeParams.teamName
				});
				$scope.processItem.$promise.then(function (res) {

					if (!res || !res.detailviews) {
						ViewsService.hasTeamView(false);
						ViewsService.hasTeamMemberView(false);
						$scope.unavailable = true;
						return;
					}

					$log.debug('hasteamview ' + res.hasTeamView);
					ViewsService.hasTeamView(res.hasTeamView ? true : false);
					ViewsService.hasTeamMemberView(res.hasTeamMemberView ? true : false);

					// store the process data
					// get the details
					var detail;
					if (res) {
						angular.forEach(res.detailviews, function (currentView) {
							if (currentView.isDefault) {
								detail = currentView;
							}
						});

						// pick first detail view if none set as default

						// what happens when user switches between views
						// TODO
						if (!detail && res.detailviews && res.detailviews.length > 0) {
							detail = res.detailviews[0];
						}

						if (detail) {
							$scope.processItem = res;
							$scope.processItem.detailViewName = detail.name;
							$scope.processItem.detailView = detail.url;
							$scope.anothertest = $scope.testing;

							$scope.dataId = detail.name;

							// get process data
							if (res.data) {
								var data = JSON.parse(res.data);
								handleProcessData(data);
							} else {
								var deferredProcData = ProcessDataFactory.query({
									teamMemberId: ContextFactory.teamMemberId,
									processId: res.id,
									dataType: 'views',
									dataId: detail.name,
									team: $routeParams.teamName
								});
								// $log.debug('$scope.minDate**************************loading');
								deferredProcData.$promise.then(function (data) {
									handleProcessData(data);
								});
							}

							$scope.updateBadges(ActionsFactory.query({}));
						} else {
							$log.warn('Process not available');
							ContextFactory.selectTeamMember(ContextFactory.teamMemberId, true, true);
						}
					} else {
						$log.error('Failed to load process');
						ContextFactory.selectTeamMember(ContextFactory.teamMemberId, true, true);
					}

				}, function (reason) {
					$log.debug('Failed to load process: ' + reason);
					ViewsService.hasTeamView(false);
					ViewsService.hasTeamMemberView(false);
					$scope.unavailable = true;
				});
			};

			$scope.doOperationOnItem = function (operationId, params, item, childId, teamMemberId) {
				if (!item) {
					$log.debug('no item provided');
					return;
				}

				var refresh;
				angular.forEach(item.operations, function (operation) {
					$log.debug('matching operationid ' + operation.id);
					if (operation.id == operationId) {
						refresh = operation.refresh;
					}
				});

				if (!refresh) {
					$log.debug('no operation found');
					return;
				}

				$scope.doOperation(operationId, params, item.id, childId, refresh, teamMemberId);
			}

			$scope.doOperation = function (operationId, params, itemId, childId, refresh, teamMemberId, processId) {
				var warnAndInfoShown = false;
				if ($scope.errors && (($scope.errors.warnings && $scope.errors.warnings.length>0) || ($scope.errors.information && $scope.errors.information.length>0))) {
					warnAndInfoShown = true;
				}

				// need a confirmation factory
				var d = $q.defer();
				var operation = new ProcessDataFactory();
				operation.params = params;
				operation.$save({
					"teamMemberId": teamMemberId ? teamMemberId : ContextFactory.teamMemberId,
					"processId": processId ? processId : $routeParams.processId,
					"dataType": "operations",
					"dataId": operationId,
					"itemId": itemId,
					"childId": childId
				}).then(function (result) {
					if (result.result) {

						$scope.errors = result;

						$log.debug('Refreshing after operation ' + operationId);

						if (result.refresh) {
							refresh = result.refresh;
						}

						if (!refresh) {
							angular.forEach($scope.processItem.operations, function (operation, i) {
								if (operation.id == operationId) {
									refresh = operation.refresh;
								}
							});
						}

						// find the operation
						if (refresh) {
							$log.debug('Performing refresh: ' + refresh);
							// update view
							if (refresh == 'user') {
								UserFactory.reload();
							} else if (refresh == 'page') {
								// clear the cache
								CategoryFactory.clear();

								UserFactory.loaded();
								$scope.refreshProcess();
							} else if (refresh == 'page_and_actions') {
								// clear the caches
								ActionsFactory.clear();
								CategoryFactory.clear();

								UserFactory.loaded();
								$scope.refreshProcess();
							} else if (refresh == 'process' || refresh == 'item') {
								// TODO - handle item refreshes more efficiently for items
								$scope.refreshProcess();
							} else if (refresh == 'process_and_actions' || refresh == 'item_and_actions') {
								// refresh just the process and the actions
								ActionsFactory.clear();
								$scope.refreshProcess();
							} else if (refresh == 'next') {

								// request next operation

								// for now this only works for operations defined on the process
								// and assumes that the steps each fill in part of the data on the same object
								var nextParams = {dataId: result.next};
								$timeout(function () {
									if (result.openNextInIFrame) {
										$scope.openFrame(nextParams, result.response ? result.response : params);
									} else {
										$scope.open(nextParams, result.response ? result.response : params);
									}
								}, 500); // give time for the previous modal to close before opening the next modal so it can pick up the windowClass

								//$scope.open(nextParams, result.response ? result.response : params);

							} else if (refresh == 'none' || refresh == 'continue') {
								// do nothing
							} else {
								$log.debug('Unsupported refresh option' + operation.refresh);
							}

						} else {
							$log.debug('operation not found');
						}

						if ((result.warnings || result.information) && refresh != 'next' && !warnAndInfoShown) {
							$timeout(function () {
								confirmWarning(result);
							}, 0);
						}
					}
					d.resolve(result);
				});
				return d;

			};

			$scope.getOperationData = function (params, teamMemberId, processId) {

				// build query properties
				var props = {
					teamMemberId: teamMemberId ? teamMemberId : ContextFactory.teamMemberId,
					processId: processId ? processId : $routeParams.processId,
					dataType: 'operations'
				};

				for (var key in params) {

					$log.debug('forwarding query parameter ' + key + ' = ' + params[key]);

					if (params.hasOwnProperty(key)) {
						props[key] = params[key];
					}
				}

				return ProcessDataFactory.get(props);
			};

			$scope.toDate = function (string) {
				if (string) {
					var parts = string.match(/(\d+)/g);
					return new Date(parts[0], parts[1] - 1, parts[2]);
				} else {
					//return;
					// $log.debug('Date string undefined');
				}
			};

			$scope.hasEditable = function (group) {

				var editable = false;

				angular.forEach(group.values, function (field, key) {
					if (!field.readonly) {
						editable = true;
					}
				});

				return editable;
			};

			$scope.refreshOperationData = function (params, operationDataItem, teamMember) {

				// get the operation
				var operation;
				var d = $q.defer();
				if (params.dataId) {
					if (params.item) {
						params.itemId = params.item.id;

						angular.forEach(params.item.operations, function (op) {
							if (op.id === params.dataId) {
								operation = op;
							}
						});

						// remove from params
						delete params.item;
					} else {
						operation = $scope.getOperationById(params.dataId,$scope.processItem.operations);
					}
				} else if (params.op) {
					operation = params.op;

					params.dataId = operation.id;

					// remove from params
					delete params.op;
				}

				if (!operation) {
					$log.debug("unable to find operation");

					return;
				}

				if (!operationDataItem) {
					var operationdata = $scope.getOperationData(params, teamMember ? teamMember.id : ContextFactory.teamMemberId, operation.processId);

					operationdata.$promise.then(function (data) {
						d.resolve(data);
					});
					return d;
				}
			};


			function openFrameModalWithData(params, operation, data, teamMember) {
        if (($window.device) && (params.url.substr(0,5) == '/apex')) {
          params.url = $window.forcetk.instanceUrl + params.url;
        }
        // if it's mobile and an absolute external URL
        if (($window.device) && (params.url.substr(0,4) == 'http')) {
           operationModalOpen = false;
			     var ref = $window.cordova.InAppBrowser.open(params.url, '_blank', 'EnableViewPortScale=yes;Location=no');
           ref.addEventListener('exit', function() { $window.location.reload()});
        } else {
           var modalInstance = $modal.open({
             templateUrl: AppConstants.MODALIFRAMEVIEWSHTML,
             controller: 'ModalInstanceCtrl',
             backdrop: 'static',
             windowClass: 'app-modal-window',
             resolve: {
               modalParams: function () {
                 return {
                   teamMember: teamMember ? teamMember : ContextFactory.teamMember.teamMember,
                   itemId: params.itemId,
                   processId: $routeParams.processId,
                   childId: params.childId,
                   items: data,
                   titleModal: params.titleModal,
                   urlFrame: params.url,
                   operation: operation,
                   parentScope: $scope
                 };
               }
             }
           });
            modalInstance.result.then(function (result) {
            $log.debug('modal closed');

            operationModalOpen = false;
          }, function () {
            operationModalOpen = false;
          });
        }
			}

			$scope.openFrame = function (params, operationDataItem, teamMember) {
				if (operationModalOpen) {
					$log.debug('Modal already open');
					return;
				}
				// $scope.processItem.operations
				// get the operation
				var operation;

				if (params.dataId) {
					if (params.item) {
						$log.debug(params.item.url);
						params.itemId = params.item.id;

						angular.forEach(params.item.operations, function (op) {
							if (op.id === params.dataId) {
								params.titleModal = op.name;
								params.url = op.url;
								operation = op;
							}
						});
						// remove from params
						delete params.item;
					} else {
						if (operationDataItem) {
							operation = $scope.getOperationById(params.dataId, operationDataItem.operations);
						} else {
							operation = $scope.getOperationById(params.dataId, $scope.processItem.operations);
						}
						if (operation) {
							params.titleModal = operation.name;
							params.url = operation.url;
						}
					}
				} else if (params.op) {
					operation = params.op;

					params.dataId = operation.id;

					// remove from params
					delete params.op;
				}

				if (!operation) {
					$log.debug("unable to find operation");
					return;
				}

				operationModalOpen = true;
				openFrameModalWithData(params, operation, operationDataItem, teamMember ? teamMember : ContextFactory.teamMember.teamMember);

			};

			$scope.open = function (params, operationDataItem, teamMember) {

				if (operationModalOpen) {
					$log.debug('Modal already open');
					return;
				}

				// get the operation
				var operation;
				if (params.dataId) {
					if (params.item) {
						params.itemId = params.item.id;

						angular.forEach(params.item.operations, function (op) {
							if (op.id === params.dataId) {
								operation = op;
							}
						});

						// remove from params
						delete params.item;
					} else {
						operation = $scope.getOperationById(params.dataId, $scope.processItem.operations);
					}
				} else if (params.op) {
					operation = params.op;

					params.dataId = operation.id;

					// remove from params
					delete params.op;
				}

				if (!operation) {
					$log.debug("unable to find operation");

					return;
				}

				operationModalOpen = true;

				if (!operationDataItem) {
					var operationdata = $scope.getOperationData(params, teamMember ? teamMember.id : ContextFactory.teamMemberId, operation.processId);

					operationdata.$promise.then(function (data) {
						openModalWithData(params, operation, data, teamMember ? teamMember : ContextFactory.teamMember.teamMember);
					}, function () {
						// cancel
						operationModalOpen = false;
					});
				} else {
					openModalWithData(params, operation, operationDataItem, teamMember ? teamMember : ContextFactory.teamMember.teamMember);
				}
			};

			$scope.viewItemInModal = function (viewName, itemIdOrItem, flags, teamMemberId, teamMemberName) {
				function openViewModal(itemId, data, url) {
					var modalInstance = $modal.open({
						templateUrl: AppConstants.MODALITEMVIEWSHTML,
						// templateUrl: operation.url,
						controller: 'ModalViewItemCtrl',
						backdrop: 'static',
						resolve: {
							modalParams: function () {
								return {
									teamMember: {
										name: teamMemberName ? teamMemberName : ContextFactory.teamMember.teamMember.name,
										id: teamMemberId ? teamMemberId : ContextFactory.teamMemberId
									},
									processId: $routeParams.processId,
									itemId: itemId,
									items: data,
									viewUrl: url,
									parentScope: $scope,
									flags: flags
								};
							}
						}
					});

					modalInstance.result.then(function (result) {
							$log.debug('modal closed');

							itemModalOpen = false;
						}, function () {
							itemModalOpen = false;
						}
					);

				}

				// lookup the view url
				if (!$scope.processItem || !$scope.processItem.itemviews || $scope.processItem.itemviews.length == 0) {
					$log.error('No item views for this process');
					return;
				}

				if (!itemIdOrItem) {
					$log.error('No item id');

					return;
				}

				if (itemModalOpen) {
					$log.debug('Modal already open');

					return;
				}

				var itemView;
				angular.forEach($scope.processItem.itemviews, function (view) {
					if (view.name == viewName) {
						if (itemView) {
							$log.error('Duplicate item views');
						} else {
							itemView = view;
						}
					}
				});


				if (!itemView) {
					$log.error('No item view for this process: ' + viewName);

					return;
				}

				if (typeof itemIdOrItem != 'string' && !itemIdOrItem.id) {
					$log.error('No id for data');

					return;
				}

				itemModalOpen = true;

				if (typeof itemIdOrItem == 'string') {
					var deferredProcData = ProcessDataFactory.get({
						teamMemberId: teamMemberId ? teamMemberId : ContextFactory.teamMemberId,
						processId: $routeParams.processId,
						dataType: 'views',
						dataId: 'item',
						itemId: itemIdOrItem
					});

					deferredProcData.$promise.then(function (data) {
						openViewModal(itemIdOrItem, data, itemView.url);
					}, function () {
						// cancel
						itemModalOpen = false;
					});
				} else {
					openViewModal(itemIdOrItem.id, itemIdOrItem, itemView.url);
				}

			};


			$scope.getOperationById = function (operationId, operationsList) {
				var res;
				angular.forEach(operationsList,function (op, ind) {
					if (op.id === operationId) {
						res = operationsList[ind];
					}
				});
				return res;

			};


			$scope.isOperationSupported = function (processOrItem, operationId) {
				if (!processOrItem || !processOrItem.operations) {
					return false;
				}

				var result = false;
				angular.forEach(processOrItem.operations, function (op) {
					if (op.id === operationId) {
						result = true;

					}
				});

				return result;
			};

			$scope.operationHasForm = function (processOrItem, operationId) {
				if (!processOrItem || !processOrItem.operations) {
					return false;
				}

				var found;
				angular.forEach(processOrItem.operations, function (op) {
					if (op.id == operationId) {
						found = op;
					}
				});

				return (found && found.url) ? true : false;
			};

			$scope.doInlineOperation = function (operationId, args, itemId) {
				//alert("Inline operation " + JSON.stringify(args));
				$scope.doOperation(operationId, args, itemId);
			}

			function getProcessWhenContextLoaded() {
				ContextFactory.callWhenLoaded(function (context) {
					//$log.debug('context loaded');
					$scope.refreshProcess();
				});
			}

			$scope.getConfirmationMessage = function (processOrItem, operationId, defaultMsg) {

				var confMessage = defaultMsg;
				angular.forEach(processOrItem.operations, function (op) {
					$log.debug('operation id is ' + op.id);
					if (op.id == operationId && op.confirmationMessage) {
						$log.debug('confirmation message is ' + op.confirmationMessage);
						confMessage = op.confirmationMessage;
					}
				});
				return confMessage;
			};

			$scope.$watch(function () {
				return ActionsFactory.isClear();
			}, function (newval, oldval) {
				if ($scope.rows && !$scope.rows) {
					// only get actions for yourself
					if (UserFactory.teamMemberId == ContextFactory.teamMemberid) {
						$scope.updateBadges(ActionsFactory.query({}));
					} else {
						$scope.actions = [];
					}
				}
			});

			$scope.updateBadges = function (actions) {
				$log.debug('Updating badges');
				actions.$promise.then(function (result) {
					$scope.actions = [];
					var team = $routeParams.teamName ? true : false;
					angular.forEach(result, function (action) {
						if ($scope.processItem.processType == action.processType && (!action.processId || action.processId == $routeParams.processId)) {
							if ((!team && ContextFactory.teamMemberId == action.teamMemberId) || (team && ContextFactory.teamMemberId != action.teamMemberId)) {
								$scope.actions.push(action);
							}
						}
					});
				});
			};

			$scope.hasAction = function (operationId, itemId) {

				var found = false;
				if ($scope.actions) {
					angular.forEach($scope.actions, function (action) {
						if (action.operationId == operationId && ((!itemId && !action.itemId) || action.itemId == itemId)) {
							found = true;
						}
					});
				}
				return found;
			};

			$scope.countActions = function (teamMemberId) {
				if (!teamMemberId) {
					if ($scope.actions) {
						return $scope.actions.length;
					}
				}

				var count = 0;
				if ($scope.actions) {
					angular.forEach($scope.actions, function (action) {
						if (action.teamMemberId == teamMemberId) {
							count++;
						}
					});
				}
				return count;
			};

			$scope.downloaddocument = function(url) {
				$window.open(url,'_system');
      		}

			$scope.selectTeamMemberView = function(teamMemberId) {
				if ($routeParams.categoryId) {
					ContextFactory.setYourPath(teamMemberId, $routeParams.categoryId, $routeParams.processId);
				} else {
					$log.error('Unknown path');
				}
			};


			getProcessWhenContextLoaded();

		}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
.controller('TabCtrl', ['$scope', function ($scope) {
        $scope.tabLoaded = true;
}]);





/* EOF */
'use strict';

angular.module('fairsailWX')

    .controller('TeamCalendarCtrl', ['$scope', '$locale', '$window', 'pickadateUtils','$timeout','ContextFactory', 'ProcessDataFactory', '$routeParams', 'dateFilter', '$document', '$location', '$log',
    function ($scope, $locale, $window, pickadateUtils,$timeout,ContextFactory, ProcessDataFactory, $routeParams, dateFilter, $document, $location, $log) {

        var absenceDataCount = 0;
        $scope.openLegends = false;


        $scope.checkLegends = function () {
            if($scope.openLegends) {
                $scope.openLegends = false;

            } else {
                $scope.openLegends = true;

            }
        };
        //calendar config for currentAbsences
        Date.prototype.yyyymmdd = function() {

            var yyyy = this.getFullYear().toString();
            var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
            var dd  = this.getDate().toString();

            return yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
        };
        Date.prototype.addHours = function(h) {
            this.setTime(this.getTime() + (h*60*60*1000));
            return this;
        };

        function isDateDisabled(dateClass) {
            return (/pickadate-disabled/.test(dateClass) || /pickadate-coyholiday/.test(dateClass));
        };

        $scope.allSelectedDates = [];


        $scope.teammembersCollection = [];

        $scope.parentobj = {
            teammembersCollection : [],
            clickCount : [],
            allTeamMembersWeek : [],
            allTeamMembers : []
        };


        $scope.allAbsencesTeam = [];
        $scope.managersID = ContextFactory.teamMemberId;

        $scope.ctrlFn = function(arg1, displayMode) {

           // var hello = function () {
                if(displayMode=='desktop') {
                    var section2 = angular.element(document.getElementById('section-' + arg1));
                   // $document.scrollToElementAnimated(section2);
                }
                if(displayMode=='mobile') {
                    var section2 = angular.element(document.getElementById('section-mobile-' + arg1));
                   // $document.scrollToElementAnimated(section2);
                }
           // }
          //  hello();

        };
        $scope.showDetails = function (dateObj, dateClass, teamMemberId, teamMemberName, absenceId, reportingRelationship) {
            if (isDateDisabled(dateClass)) {
                return;
            }

			if (reportingRelationship == 'Translate YOU' || reportingRelationship == 'fHCM2__Global_Direct_Report') {
				$scope.viewItemInModal('absence item', absenceId, undefined, teamMemberId, teamMemberName);
			}
        };

        $scope.startDateOperation = function (dateObj, dateClass, displayMode) {
            if (isDateDisabled(dateClass)) {
                return;
            }

                var keepGoing = true;
                angular.forEach($scope.allAbsences, function (thisDate) {
                    if (keepGoing) {
                        if (thisDate.myDate === dateObj) {
                            $log.debug('Date in Absences : ' + thisDate.myDate);
                            $scope.selectedObject = thisDate.myObject;
                            keepGoing = false;
                            $scope.viewItemInModal('absence item', thisDate.myObject.id);
                        }
                    }
                });

                if (keepGoing) {
                    // alert(dateObj);
                    $scope.dateCount = $scope.allSelectedDates.length;
                    $scope.dateCounter = 0;
                    if ($scope.dateCount == 0) {
                        $scope.allSelectedDates.push(dateObj);
                        $scope.vacationDates.push(dateObj);
                        $scope.dateCounter++;
                        $scope.date = dateObj;
                        $log.debug('date 1 ' + dateObj);
                    }
                    if ($scope.dateCount == 1) {
                        $scope.allSelectedDates.push(dateObj);
                        // $scope.vacationDates = [];
                        var start = $scope.allSelectedDates[0],
                            end = $scope.allSelectedDates[1],
                            currentEndDate = new Date(end),
                            currentDate = new Date(start);
                        $log.debug("calendar config for start = " + $scope.allSelectedDates[0]);
                        while (currentDate <= currentEndDate) {
                            $log.debug('calendar date=' + new Date(currentDate).yyyymmdd());
                            $scope.vacationDates.push(new Date(currentDate).yyyymmdd());
                            $scope.date = new Date(currentDate).yyyymmdd();
                            currentDate.setDate(currentDate.getDate() + 1);

                        }

                        var params = {dataId: 'create_select_reason', startDate: start, endDate: end};
                        $scope.open(params);


                    }
                    if ($scope.dateCount == 2) {
                        $scope.allSelectedDates = [];
                        $scope.vacationDates = [];
                        $scope.allSelectedDates.push(dateObj);
                        $scope.vacationDates.push(dateObj);
                        $scope.date = dateObj;
                        $log.debug('date 1 ' + dateObj);
                    }

                }
        };

        $scope.changeYearOperation = function (year){
			var deferredProcData = ProcessDataFactory.query({
				teamMemberId: ContextFactory.teamMemberId,
				"processId": $routeParams.processId,
				dataType: 'views',
				dataId: 'detail',
				team: $routeParams.teamName,
				startYear: year
			});

			deferredProcData.$promise.then(function (data) {
				$scope.processItem.data = data;
			});

			absenceDataCount = 0;

			$scope.teamData = false;
			$scope.spinner = true;
		};

        $scope.$watch('processItem.data', function (newVal, oldVal) {
            if (!newVal) {
                return;
            }

			$scope.dataLoaded = true;

            var data = newVal;

            $scope.spinner = true;

            //$log.debug('TeamMembers now in processItem.data' + JSON.stringify(newVal));

            $scope.dayoffDates = []; // Absences
            $scope.vacationDates = []; // current selection
            $scope.holidayDates = []; // Paid Time Off
            $scope.allAbsences = []; // ALL ABSENCES dates + Labels
            $scope.allCoyholidays = []; // ALL Company Holiday Dates + Labels
            $scope.coyholidayDates = []; // company holiday dates
            $scope.weekendDates = []; // weekends dates
            $scope.setMonths = 12;
            $scope.teammembersCollection = [];
            $scope.parentobj.teammembersCollection = [];



            //$log.debug("absence data from processItem.data----------------------------------");
            $scope.workingDaysInStartYear = data.teamMember.workingDaysInStartYear;
            $scope.workingDaysInEndYear = data.teamMember.workingDaysInEndYear;

			$scope.minDate = pickadateUtils.stringToDate(dateFilter(data.teamMember.yearStart, 'yyyy-MM-dd'));
			$scope.maxDate = pickadateUtils.stringToDate(dateFilter(data.teamMember.yearEnd, 'yyyy-MM-dd'));

            //Fillup weekendDates from workingDaysInStartYear array object
            var getWorkingDaysInStartYear = getWeekEnds($scope.workingDaysInStartYear);

            //Fillup weekendDates from workingDaysInEndYear array object
            var getWorkingDaysInEndYear = getWeekEnds($scope.workingDaysInEndYear);

            $scope.weekendDates = getWorkingDaysInStartYear.weekEndsDates.concat(getWorkingDaysInEndYear.weekEndsDates);
            $scope.allCoyholidays = getWorkingDaysInStartYear.allCoyDates.concat(getWorkingDaysInEndYear.allCoyDates);
            $scope.coyholidayDates = getWorkingDaysInStartYear.coysDates.concat(getWorkingDaysInEndYear.coysDates);

			loadTeam(data, $scope.parentobj.teammembersCollection);


                var mydataAbsence = data.teamMember.calendarItems;
                var allAbsencesTeamYou = [], dayoffDatesTeamYou = [], holidayDatesTeamYou = [];
                var thisDirectReports = [];

               //if (_.findWhere($scope.parentobj.clickCount, {id: ContextFactory.teamMemberId}) == '')
                var checkClickCount = false;
                angular.forEach($scope.parentobj.clickCount, function(x){
                    if(x.id == ContextFactory.teamMemberId){
                        checkClickCount = true
                    }
                });

                if(!checkClickCount) {
                    $scope.parentobj.clickCount.push({id: ContextFactory.teamMemberId, loaded: false, open: false});
                }

                $scope.allAbsencesTeam.push({calendarTeamAllAbsences: allAbsencesTeamYou, teamMemberId: ContextFactory.teamMemberId});
                $scope.allAbsences = allAbsencesTeamYou;
                $scope.dayoffDates = dayoffDatesTeamYou; // Absences
                $scope.vacationDates = []; // current selection
                $scope.holidayDates = holidayDatesTeamYou; // Paid Time Off
                // $log.debug('ContextFactory.teamMember.teamMember.jobTitle-----------------------------> '+ContextFactory.teamMember.teamMember.jobTitle)
                $scope.date = new Date().yyyymmdd();

                $scope.render();

            dataReady();


        }, true);


        $scope.$watch(function(){
            return $window.innerWidth;
        }, function(newValue, oldValue) {
            $log.debug('$scope.winWidth ===================>>>'+newValue);

			if (newValue) {
				if (newValue < 768) {
					$scope.showWeek = true;
				} else {
					$scope.showWeek = false;
				}

				if (newValue != oldValue && $scope.currentDate) {
					if ($scope.showWeek == false) {
						$scope.currentDate = new Date($scope.currentDate.getFullYear(), $scope.currentDate.getMonth(), 1, 3);
					} else {
						var initialDate = new Date(moment($scope.currentDate).startOf('week').format('YYYY-MM-DD'));
						if (initialDate.getMonth() != $scope.currentDate.getMonth()) {
							$scope.currentDate = new Date(moment($scope.currentDate).add(7, 'days').startOf('week').format('YYYY-MM-DD'));
						} else {
							$scope.currentDate = initialDate;
						}
					}
				}

				$scope.render();
			}
		});

        $scope.render = function () {
			function processDates(teamMember, allDates, teamMembersDisplay) {
				var dates = [];

				for (var i = 0; i < allDates.length; i++) {
					var className = "", tooltipMessage = "", myTooltipMessage = "", myAbsenceStatus = "", date = allDates[i];
					var myAbsenceId;

					if (teamMember.calendarTeamDaysoffDates && indexOf.call(teamMember.calendarTeamDaysoffDates, date) >= 0) {
						className = 'pickadate-enabled pickadate-dayoff';
						angular.forEach(teamMember.calendarTeamAllAbsences, function (thisDate) {
							if (thisDate.myDate === date) {
								myTooltipMessage = thisDate.myReason;
								myAbsenceStatus = thisDate.myStatus;
								myAbsenceId = thisDate.myObject.id;
							}
						});
						tooltipMessage = myTooltipMessage;

					} else if (indexOf.call($scope.vacationDates, date) >= 0) {
						className = 'pickadate-enabled pickadate-vacation';
					} else if (teamMember.calendarTeamHolidayDates && indexOf.call(teamMember.calendarTeamHolidayDates, date) >= 0) {
						//$log.debug('dates holiday = '+date)
						className = 'pickadate-enabled pickadate-holiday';
						angular.forEach(teamMember.calendarTeamAllAbsences, function (thisDate) {
							if (thisDate.myDate === date) {
								myTooltipMessage = thisDate.myReason;
								myAbsenceStatus = thisDate.myStatus;
								myAbsenceId = thisDate.myObject.id;
							}
						});
						tooltipMessage = myTooltipMessage;
					} else if (teamMember.calendarTeamCoyHoliday && indexOf.call(teamMember.calendarTeamCoyHoliday, date) >= 0) {
						//$log.debug('dates holiday = '+date)
						className = 'pickadate-enabled pickadate-coyholiday';
						angular.forEach(teamMember.calendarTeamAllCoyHolidaysTeam, function (thisDate) {
							if (thisDate.myDate === date) {
								myTooltipMessage = thisDate.myLabel;

							}
						});
						tooltipMessage = myTooltipMessage;
					} else if (teamMember.calendarTeamWeekEnd && indexOf.call(teamMember.calendarTeamWeekEnd, date) >= 0)
					{
						className = 'pickadate-disabled pickadate-weekend';
						// $log.debug('teamMember.calendarTeamWeekEnd£££££££££££££££££££££££££££££££££££££‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ '+teamMember.calendarTeamWeekEnd);
					}
					else {
						className = 'pickadate-enabled';
					}

					if (date === today) {
						className += ' pickadate-today';
					}

					dates.push({date: date, className: className, tooltipMessage: tooltipMessage, myAbsenceStatus: myAbsenceStatus, myAbsenceId: myAbsenceId});

				}

				var teamDirectReports = [];
				angular.forEach(teamMember.calendarTeamThisDirectReports, function(t){
					processDates(t, allDates, teamDirectReports);
				});

				teamMembersDisplay.push(
					{
						calendarTeamID: teamMember.calendarTeamID,
						calendarTeamName: teamMember.calendarTeamName,
						calendarTeamJobTitle: teamMember.calendarTeamJobTitle,
						calendarTeamRelationship: teamMember.calendarTeamRelationship,
						calendarTeamPhoto: teamMember.calendarTeamPhoto,
						calendarTeamDisplayStatus: teamMember.calendarTeamDisplayStatus,
						calendarTeamDates: dates,
						calendarTeamDirectReports: teamDirectReports,
						calendarTeamShow: teamMember.calendarTeamShow
					}
				);

			}

			if ($scope.showWeek == undefined || !$scope.dataLoaded) {
				return;
			}

			var initialDate;
			if ($scope.currentDate) {
				initialDate = $scope.currentDate;
			} else {
				initialDate = new Date(dateFilter(new Date(), 'yyyy-MM-dd'));
				if ($scope.showWeek == false) {
					initialDate = new Date(initialDate.getFullYear(), initialDate.getMonth(), 1, 3);
				} else {
					initialDate = new Date(moment(initialDate).startOf('week').format('YYYY-MM-DD'));
				}
			}


            var currentMonth = initialDate.getMonth() + 1,
                dayCount = $scope.showWeek ? 7 : new Date(initialDate.getFullYear(), initialDate.getMonth() + 1, 0, 3).getDate(),
                currentMonthDates = pickadateUtils.dateRange(0, dayCount, initialDate);

            var allDates = currentMonthDates,
                coyDates = [], allTeamMembers = [],
                today = dateFilter(new Date(), 'yyyy-MM-dd');

            $scope.currentDate = pickadateUtils.stringToDate(dateFilter(initialDate, 'yyyy-MM-dd'));

            var nextMonthInitialDate = new Date(initialDate);
            nextMonthInitialDate.setMonth(currentMonth);

            var indexOf = [].indexOf || function (item) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && this[i] === item) return i;
                }
                return -1;
            };
            $scope.allowPrevMonth = true;
            $scope.allowNextMonth = true;
            angular.forEach($scope.parentobj.teammembersCollection, function (teamMember) {
				processDates(teamMember, allDates, allTeamMembers);

            });
            $log.debug('allTeamMembers.push-----------------------------' + allTeamMembers.length);

            for (var i = 0; i < allDates.length; i++) {
                var className = "", tooltipMessage = "", myTooltipMessage = "", date = allDates[i];

                if (dateFilter(date, 'M') !== currentMonth.toString()) {
                    className = 'pickadate-disabled';
                    //className = 'pickadate-enabled';
                } else if (indexOf.call($scope.coyholidayDates, date) >= 0) {
                    //$log.debug('dates holiday = '+date)
                    className = 'pickadate-enabled pickadate-coyholiday';
                    angular.forEach($scope.allCoyholidays, function (thisDate) {
                        if (thisDate.myDate === date) {
                            myTooltipMessage = thisDate.myLabel;
                        }
                    });
                    tooltipMessage = myTooltipMessage;
                } else if (indexOf.call($scope.weekendDates, date) >= 0)
                    className = 'pickadate-disabled pickadate-weekend';
                else {
                    className = '';
                }

                if (date === today) {
                    className += ' pickadate-today';
                }

                coyDates.push({date: date, className: className, tooltipMessage: tooltipMessage});

            }

            $scope.coyDates = coyDates;

			var sortObj = _.sortBy(allTeamMembers, "calendarTeamRelationship");
            var translateYouObj = _.where(sortObj, {calendarTeamRelationship: "Translate YOU"});
            var colleagueObj = _.where(sortObj, {calendarTeamRelationship: "fHCM2__Global_Colleague"});
            var directReportObj = _.where(sortObj, {calendarTeamRelationship: "fHCM2__Global_Direct_Report"});
			var managerObj = _.where(sortObj, {calendarTeamRelationship: "fHCM2__Global_Manager"});
			var otherObj = _.where(sortObj, {calendarTeamRelationship: "fHCM2__Global_Other"});

            var sortedObj = [];

			copyTeamMember(managerObj, sortedObj);
			copyTeamMember(translateYouObj, sortedObj);
			copyTeamMember(directReportObj, sortedObj);
			copyTeamMember(colleagueObj, sortedObj);
			copyTeamMember(otherObj, sortedObj);

            $scope.parentobj.allTeamMembers = sortedObj;
        };

		function copyTeamMember(src, dest) {
			angular.forEach(src, function(x){
				dest.push(
					{
						calendarTeamID: x.calendarTeamID,
						calendarTeamName: x.calendarTeamName,
						calendarTeamJobTitle: x.calendarTeamJobTitle,
						calendarTeamRelationship: x.calendarTeamRelationship,
						calendarTeamPhoto: x.calendarTeamPhoto,
						calendarTeamDisplayStatus: x.calendarTeamDisplayStatus,
						calendarTeamDates: x.calendarTeamDates,
						calendarTeamDirectReports: x.calendarTeamDirectReports,
						calendarTeamShow: x.calendarTeamShow
					}
				);

			});
		}

        function dataReady() {
            absenceDataCount++;

            $log.debug('data ready ' + absenceDataCount);
            if ($scope.teamMembers && absenceDataCount == ($scope.teamMembers.length + 1)) {
	       			$scope.teamData = true;
				      $scope.spinner = false;
            } else {
              $scope.teamData = false;
              $scope.spinner = false;
            }
        };

        function getWeekEnds(days){

            var weekEndsDates = [];
            var allCoyDates = [];
            var coysDates = [];

            for(var i in days){
                var key = i;
                //$log.debug('$scope.workingDaysInStartYear = '+key);
                var val = days[i];
                var wk = 0, holiday = 0, lb = '';
                for(var j in val){
                    var sub_key = j;
                    var sub_key_val = val[j];
                    if (sub_key == 'isWeekday')
                    {
                        if(sub_key_val == false)
                        {
                            wk=1;
                        }
                    }
                    if (sub_key == 'isShift')
                    {
                        if(sub_key_val == false)
                        {
                            wk = wk+1;
                        }
                    }
                    if (sub_key == 'isHoliday')
                    {
                        if(sub_key_val == true)
                        {
                            holiday = 1;
                        }
                        else holiday = 0;
                    }
                    if (sub_key == 'label')
                    {
                        if(sub_key_val != null)
                        {
                            lb = sub_key_val;
                        }
                    }
                    //$log.debug(sub_key+' = '+val[j]);
                }
                // $log.debug(wk+' = '+holiday+' = '+lb);
                if(wk==2){
                    //its weekend
                    // var newKey  = dateFilter(new Date(key.toString()), 'yyyy-MM-dd')
                    // $log.debug('$scope.weekendDates = '+ moment(key).format('YYYY-MM-DD'));
                    weekEndsDates.push(moment(key).format('YYYY-MM-DD'));
                }

                if(holiday==1){
                    //its weekend
                    // $log.debug('$scope.coyholidayDates = '+key);
                    allCoyDates.push({myLabel: lb, myDate: moment(key).format('YYYY-MM-DD')});
                    coysDates.push(moment(key).format('YYYY-MM-DD'));
                }
            }
            return {
                'weekEndsDates': weekEndsDates,
                'allCoyDates': allCoyDates,
                'coysDates': coysDates
            };
        };


		function loadTeamMember(myteam, teamList, directReports, show, hasTeam) {
			var calTeamMemberName = myteam.teamMemberName,
				calTeamMemberjobTitle = myteam.jobTitle,
				calTeamMemberPhoto = myteam.teamMemberPictureUrl,
				calTeamMemberID = myteam.teamMemberId,
				allAbsencesTeam = [], dayoffDatesTeam = [], holidayDatesTeam = [];
			var displayStatus = true;
			var allCoyholidaysTeam = [];
			var coyholidayDatesTeam = [];
			var weekendDatesTeam = [];


			var calTeamMemberRelationship = '';
			if (myteam.reportingRelationship == 'self') {
				calTeamMemberRelationship = "Translate YOU"
			} else if (myteam.reportingRelationship == 'direct report') {
				calTeamMemberRelationship = "fHCM2__Global_Direct_Report"
			} else if (myteam.reportingRelationship == 'colleague') {
				calTeamMemberRelationship = "fHCM2__Global_Colleague"
			} else if (myteam.reportingRelationship == 'other') {
				calTeamMemberRelationship = "fHCM2__Global_Other"
			} else if (myteam.reportingRelationship == 'manager') {
				calTeamMemberRelationship = "fHCM2__Global_Manager"
			}

			var mydataAbsence = myteam.calendarItems;
			var workingDaysInStartYear = myteam.workingDaysInStartYear;
			var workingDaysInEndYear = myteam.workingDaysInEndYear;

			//Fillup weekendDates from workingDaysInStartYear array object
			var getWorkingDaysInStartYear = getWeekEnds(workingDaysInStartYear);

			//Fillup weekendDates from workingDaysInEndYear array object
			var getWorkingDaysInEndYear = getWeekEnds(workingDaysInEndYear);

			weekendDatesTeam = getWorkingDaysInStartYear.weekEndsDates.concat(getWorkingDaysInEndYear.weekEndsDates);
			allCoyholidaysTeam = getWorkingDaysInStartYear.allCoyDates.concat(getWorkingDaysInEndYear.allCoyDates);
			coyholidayDatesTeam = getWorkingDaysInStartYear.coysDates.concat(getWorkingDaysInEndYear.coysDates);

			angular.forEach(mydataAbsence, function (myitem) {

				var start = myitem.startDate,
					end = myitem.endDate,
					dcurrentEndDate = new Date(end),
					dcurrentDate = new Date(start),
					currentEndDate = new Date(dcurrentEndDate.addHours(dcurrentEndDate.getTimezoneOffset()/60)),
					currentDate = new Date(dcurrentDate.addHours(dcurrentDate.getTimezoneOffset()/60));
				//  $log.debug(' currentDate********************************** '+ currentDate)
				while (currentDate <= currentEndDate) {
					//$log.debug('myitem.reason.value date=' + myitem.reason.value);

					if (_.indexOf(weekendDatesTeam, moment(currentDate).format('YYYY-MM-DD')) >= 0) {
						$log.debug('Weekend is there!');
					} else if(_.indexOf(coyholidayDatesTeam, moment(currentDate).format('YYYY-MM-DD')) >= 0){
						$log.debug('Coy Holiday is there!');
					} else {
						allAbsencesTeam.push({myReason: myitem.status+' '+myitem.reason.value, myStatus: myitem.status, myObject: myitem, myDate: moment(currentDate).format('YYYY-MM-DD')});
						if (myitem.recordTypeName == 'Vacation') {
							dayoffDatesTeam.push(moment(currentDate).format('YYYY-MM-DD'));
						}
						if (myitem.recordTypeName == 'Absence') {
							holidayDatesTeam.push(moment(currentDate).format('YYYY-MM-DD'));
						}
					}

					currentDate.setDate(currentDate.getDate() + 1);
				}

			});

			//   $log.debug("%c weekendDatesTeam>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+weekendDatesTeam.length+" ", "color: green; font-size: 14px");
			//    $log.debug("%c allCoyholidaysTeam>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+allCoyholidaysTeam.length+" ", "color: green; font-size: 14px");
			//    $log.debug("%c coyholidayDatesTeam>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+coyholidayDatesTeam.length+" ", "color: green; font-size: 14px");

			teamList.push(
				{
					calendarTeamID: calTeamMemberID,
					calendarTeamWeekEnd: weekendDatesTeam,
					calendarTeamAllCoyHolidaysTeam: allCoyholidaysTeam,
					calendarTeamCoyHoliday: coyholidayDatesTeam,
					calendarTeamName: calTeamMemberName,
					calendarTeamJobTitle: calTeamMemberjobTitle,
					calendarTeamRelationship: calTeamMemberRelationship,
					calendarTeamPhoto: calTeamMemberPhoto,
					calendarTeamAllAbsences: allAbsencesTeam,
					calendarTeamDaysoffDates: dayoffDatesTeam,
					calendarTeamHolidayDates: holidayDatesTeam,
					calendarTeamDisplayStatus: hasTeam == undefined || hasTeam == true ? true : false,
					calendarTeamThisDirectReports: directReports ? directReports : [],
					calendarTeamShow: show
				}
			);

		}

		function loadTeam(data, teamList) {
			if (data.manager) {
				loadTeamMember(data.manager, teamList, undefined, false, false);
			}

			var thisDirectReports = [];

			angular.forEach(data.directReports, function (myteam) {
				loadTeamMember(myteam, thisDirectReports, undefined, false);

				dataReady();
			});

			angular.forEach(data.colleagues, function (myteam) {
				loadTeamMember(myteam, thisDirectReports, undefined, false);
			});

			loadTeamMember(data.teamMember, teamList, thisDirectReports, true);
		}

		$scope.loadTeamInExisting  = function (teamMember, data) {
			var thisDirectReports = [];

			// find object in perm list
			var tm = findTeamMember($scope.parentobj.teammembersCollection, teamMember.calendarTeamID);

			if (tm) {
				angular.forEach(data.directReports, function (myteam) {
					loadTeamMember(myteam, thisDirectReports, undefined, false);
				});

				tm.calendarTeamShow = true;
				tm.calendarTeamDisplayStatus = thisDirectReports.length > 0;
				tm.calendarTeamThisDirectReports = thisDirectReports;

				$scope.render();
			} else {
				$log.error('unable to find team member for ' + teamMember.calendarTeamName);
			}
		}

		function findTeamMember(teamMemberList, calendarTeamID) {
			var found;
			angular.forEach(teamMemberList, function (teamMember) {
				if (!found) {
					if (teamMember.calendarTeamID == calendarTeamID) {
						found = teamMember;
					} else {
						found = findTeamMember(teamMember.calendarTeamThisDirectReports, calendarTeamID);
					}
				}
			})
			return found;
		}

		$scope.openDirectReportList = function (teamMember) {
			if (teamMember.calendarTeamShow) {
				teamMember.calendarTeamShow = false;
			} else {
				teamMember.calendarTeamShow = true;
				if (teamMember.calendarTeamDisplayStatus && teamMember.calendarTeamDirectReports.length == 0) {
					var deferredProcData = ProcessDataFactory.query({
						teamMemberId: teamMember.calendarTeamID,
						"processId": $routeParams.processId,
						dataType: 'views',
						dataId: 'detail',
						team: $routeParams.teamName,
						startYear: $scope.currentDate.getFullYear()
					});


					deferredProcData.$promise.then(function (data) {
						$scope.loadTeamInExisting(teamMember, data);

					}, function (error) {
						$log.error('Failed to load ' + error);
					});
				}
			}
		};

		$scope.changeMonth = function (offset) {
			// If the current date is January 31th, setting the month to date.getMonth() + 1
			// sets the date to March the 3rd, since the date object adds 30 days to the current
			// date. Settings the date to the 2nd day of the month is a workaround to prevent this
			// behaviour
			// scope.changeyear({offset: 2016});
			//scope.currentDate.setDate(1);
			//scope.changeyear({offset: 2016});

			var minYr = $scope.minDate.getFullYear();
			var maxYr = $scope.maxDate.getFullYear();
			$scope.currentDate.setMonth($scope.currentDate.getMonth() + offset);

			var playDate = new Date($scope.currentDate);

			if(playDate.getTime() < $scope.minDate.getTime()) {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthNext = true;
				$scope.setLastMonthPrev = false;
				$scope.changeYearOperation(minYr - 1);

			} else if(playDate.getTime() > $scope.maxDate.getTime()) {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthPrev = true;
				$scope.setLastMonthNext = false;
				$scope.changeYearOperation(minYr == maxYr ? maxYr + 1 : maxYr);
			} else {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthPrev = false;
				$scope.setLastMonthNext = false;
				$scope.render();
			}
		};

		$scope.changeWeek = function (offset) {
			// If the current date is January 31th, setting the month to date.getMonth() + 1
			// sets the date to March the 3rd, since the date object adds 30 days to the current
			// date. Settings the date to the 2nd day of the month is a workaround to prevent this
			// behaviour

			var minYr = $scope.minDate.getFullYear();
			var maxYr = $scope.maxDate.getFullYear();

			$scope.currentDate = new Date($scope.currentDate.setDate($scope.currentDate.getDate() + offset));

			var playDate = new Date($scope.currentDate);

			if(playDate.getTime() < $scope.minDate.getTime()) {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthNext = true;
				$scope.setLastMonthPrev = false;
				$scope.changeYearOperation(minYr - 1);

			} else if(playDate.getTime() > $scope.maxDate.getTime()) {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthPrev = true;
				$scope.setLastMonthNext = false;
				$scope.changeYearOperation(minYr == maxYr ? maxYr + 1 : maxYr);
			} else {
				$scope.lastMonth = $scope.currentDate.getMonth();
				$scope.setLastMonthPrev = false;
				$scope.setLastMonthNext = false;
				$scope.render();
			}

		};
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .controller('TeamHierarchyCtrl', ['$scope', 'ContactFactory', 'UserFactory', 'ContextFactory','AppConstants', '$log', function ($scope, ContactFactory, UserFactory, ContextFactory, AppConstants, $log) {
        $scope.contactViewsHtml = AppConstants.CONTACTVIEWSHTML;

        $scope.isopened = true;

    $scope.directReports = [];
    $scope.crossReports = [];
    $scope.managers = [];
    $scope.colleagues = [];

    var deferred = ContactFactory.query({search:'', group:''});
    deferred.$promise.then(function (result) {
      $scope.directReports = [];
      $scope.crossReports = [];
      $scope.managers = [];
      $scope.colleagues = [];

      angular.forEach(result, function(contact) {
        if (contact) {
          if (contact.reportingRelationship == 'Direct Report') {
            $scope.directReports.push(contact);
          } else if (contact.reportingRelationship == 'Cross Report') {
            $scope.crossReports.push(contact);
          } else if (contact.reportingRelationship == 'Manager') {
            $scope.managers.push(contact);
          } else if (contact.reportingRelationship == 'Colleague') {
            $scope.colleagues.push(contact);
          } else {
            $log.error('Unknown reporting relationship for ' + contact.name);
          }
        }
      });
    });

    $scope.selectTeamMember = function(teamMemberId) {
            ContextFactory.selectTeamMember(teamMemberId, true);
        }

		$scope.openOrgChart = function (teamMemberId) {
			ContextFactory.setYourOtherPath(teamMemberId, 'orgchart');
		};

		$scope.openActions = function (teamMemberId) {
			ContextFactory.setYourOtherPath(teamMemberId, 'actions');
		};

		$scope.viewerIsManager = function () {
			return UserFactory.isManager();
		}

	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller('TeamMemberCtrl', ['$scope', '$routeParams', '$log', 'ContextFactory', 'CategoryFactory', function ($scope, $routeParams, $log, ContextFactory, CategoryFactory) {
        $log.debug('TeamMemberCtrl: ' + $routeParams.teamMemberId);

    var navigationItems = CategoryFactory.query({teamMemberId: $routeParams.teamMemberId});
    navigationItems.$promise.then(function (categories) {
      if (categories && categories.length > 0) {
        ContextFactory.selectTeamMember($routeParams.teamMemberId, true, true);
      }
    });

  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')

    .controller('TeamOrgchartCtrl', ['$scope', function ($scope) {

        $scope.openTeam = false;


        $scope.openTeamDiv = function () {
            if($scope.openTeam) {
                $scope.openTeam = false;

            } else {
                $scope.openTeam = true;

            }
        }

    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('TranslationCtrl', ['$scope', "$log", 'TranslationLoaderFactory',
		function ($scope, $log, TranslationLoaderFactory) {
			$scope.$watch(function () {
				return TranslationLoaderFactory.loaded();
			}, function (newVal, oldVal) {
				$scope.translationsLoaded = newVal;
			});
		}]);


/* EOF */
'use strict';

angular.module('fairsailWX')
	.controller('UserCtrl', ['$scope', 'UserFactory','AppConstants', 'LoadingNotifyService', '$window', '$route', 'ContextFactory', 'ProcessDataFactory', 'Utils', "$log",
		function ($scope, UserFactory, AppConstants, LoadingNotifyService, $window, $route, ContextFactory, ProcessDataFactory, Utils, $log) {

			function b64toBlob(b64Data, contentType, sliceSize) {
				contentType = contentType || '';
				sliceSize = sliceSize || 512;

				var byteCharacters = atob(b64Data);
				var byteArrays = [];

				for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
					var slice = byteCharacters.slice(offset, offset + sliceSize);

					var byteNumbers = new Array(slice.length);
					for (var i = 0; i < slice.length; i++) {
						byteNumbers[i] = slice.charCodeAt(i);
					}

					var byteArray = new Uint8Array(byteNumbers);

					byteArrays.push(byteArray);
				}

				var blob = new Blob(byteArrays, {type: contentType});
				return blob;
			}


			$scope.user = UserFactory;
			$scope.AppConstants = AppConstants;
			$scope.loading = false;
			$scope.predicate = '';

			$scope.isAdmin = $window.isAdmin;

			$scope.$watch(function () {
				return LoadingNotifyService.isLoading();
			}, function (newVal, oldVal) {
				if (newVal != null) {
					$scope.loading = newVal;
				}
			});

			// get user config info if user wasn't added to index page
			if (!$window.userViewport) {
				UserFactory.callWhenLoaded(function (teamMemberId) {

					var deferredProcData = ProcessDataFactory.query({
						teamMemberId: UserFactory.teamMemberId,
						processId: '000000000000000000',
						dataType: 'views',
						dataId: 'setup'
					});

					deferredProcData.$promise.then(function (data) {
						if (data) {
							if (data.logoBody) {
								var blob = b64toBlob(data.logoBody, 'image/jpeg');
								var blobUrl = URL.createObjectURL(blob);

								$scope.logoUrl = blobUrl;
							} else {
								$scope.logoUrl = data.logoUrl;
							}

							$scope.title = data.title;
						} else {
							$log.debug("No data returned for process");
						}
					});
				});
			}

		}]);


/* EOF */
'use strict';

angular.module('fairsailWX')
  .controller('watchCheckboxCtrl', ['$scope',  function ($scope) {

        $scope.$watch('item.ticked', function (newVal, oldVal) {

            if (newVal) {
                $scope.clearOtherProcessItems($scope.item.processId);
            }
        });
    }]);




/* EOF */
/**
 * Created by CarolineR on 14/07/2015.
 */

'use strict';

angular.module('fairsailWX')

    .directive('advancedSearch',  [ '$log', function ($log) {
        return {
            restrict: 'A',
            link: function link(scope, element, attrs) {
              if (attrs.dependentFieldPath) {
                scope.$watch(attrs.dependentFieldPath, function(newVal, oldVal) {
                  // if value of dependent field cleared, clear this selection
                  if (oldVal && (oldVal.value != (newVal ? newVal.value : '')) && attrs.ngModel) {
                    scope[attrs.advancedSearch] = {name: ''};
                  }
                  // get options
                  if (newVal && ((!oldVal || oldVal.value != newVal.value) || !newVal.value)) {
                    var dependentFieldId = attrs.dependentFieldId ? attrs.dependentFieldId : attrs.dependentFieldPath;
                    scope.populateDropdown(attrs.advancedSearch, attrs.targetId, dependentFieldId, newVal.value ? newVal.value : newVal);
                  }
                });
              } else  {
                scope.populateDropdown(attrs.advancedSearch, attrs.targetId);
              }
            }


        }
    }]);

/* EOF */
angular.module('fairsailWX')
  .directive('autocompleteInput', ['$log', 'ContextFactory', 'OperationOptionsFactory', '$timeout', function ($log, ContextFactory, OperationOptionsFactory, $timeout) {

    return {
      restrict: 'E',
      replace: true,
      scope: {
        item: '=',
        processId: '=',
        teammemberId: '=',
        operationId: '@',
        fieldId: '@',
        itemRequired: '@',
        fieldName: '@'
      },
      template: '<div>' +
      '<input class="form-control autocomplete" type="text" ng-model="searchStr">' +
      '<select  ng-show="values" class="form-control autocomplete" data-ng-attr-size="{{selectSize}}" ng-required="itemRequired" ng-model="selected" ng-click="defaultValue()" ng-change="changedValue()" ng-options="item.name for item in values track by item.value"></select>' +
      '</div>',
      link: function (scope, elem, attrs) {

          var timer = false;

        scope.$watch("searchStr", function (newValue, oldValue) {

            if (timer) {
                $timeout.cancel(timer)
            }
            timer = $timeout(function () {

          if (newValue != oldValue) {

              if (newValue.length < 1) {
                scope.values = undefined;
                scope.selected = '';
              }

              if (!scope.selected || scope.selected.name != newValue) {

                if (newValue.length >= 2) {
                  scope.partial = newValue;

                  var params = {
                    teamMemberId: scope.teammemberId,
                    processId: scope.processId,
                    operationId: scope.operationId,
                    fieldId: scope.fieldId,
                    partial: scope.searchStr,
                    nameField: scope.fieldName
                  };

                  var deferredOptions = OperationOptionsFactory.query(params);

                  deferredOptions.$promise.then(function (res) {
                    scope.values = res.options;
                    if (scope.values) {
                      scope.selectSize = scope.values.length;
                      scope.selected = scope.values[0]; //set selected value to first value returned, so that empty value not shown in list
                    }
                  });
                }
              }
            }
          }, 500)
        });

        scope.changedValue = function () {
            $log.debug('option selected, not default first option');
          scope.item = scope.selected.value;
          scope.searchStr = scope.selected.name;
          scope.values = undefined;

        };

        scope.defaultValue = function () {       /* this is used when the first (default) value is selected, even if there are many options) */
            $log.debug('default first option selected');
            scope.item = scope.selected.value;
            scope.searchStr = scope.selected.name;
            scope.values = undefined;
        };

      }
    }

  }]);


/* EOF */
/**
 * Created by CarolineR on 13/10/2014.
 */

'use strict';

angular.module('fairsailWX')
    .directive('autocompleteOptions', [ 'ContextFactory', '$routeParams', 'OperationOptionsFactory', '$log', '$timeout', function(ContextFactory, $routeParams, OperationOptionsFactory, $log, $timeout) {
        function populateAutoComplete(scope, fieldId, targetId) {
            if (!scope.options) {
                scope.options = {};
            }

            var params = {teamMemberId: ContextFactory.teamMemberId,
                processId: $routeParams.processId,
                operationId: scope.opId,
                itemId: scope.itemId,
                fieldId: fieldId,
                partial: scope.partial
            };

            var deferredOptions = OperationOptionsFactory.query(params);

            deferredOptions.$promise.then(function (res) {
                if (targetId) {
                    scope.options[targetId] = res.options;
                    scope.attribute.newValue.option = scope.options[targetId][0]; //set selected value to first value returned, so that empty value not shown in list
                    scope.selectSize = scope.options[targetId].length; // show full list by default - this value used in html select element

                } else {
                    scope.options[fieldId] = res.options;
                    scope.attribute.newValue.option = scope.options[fieldId][0]; //set selected value to first value returned, so that empty value not shown in list
                    scope.selectSize = scope.options[fieldId].length; // show full list by default - this value used in html select element
                }
            });
        };

        return {
            restrict: 'EA',
            replace: true,
            template: '<div>' +
                '<input class="form-control autocomplete" type="text" ng-model="autoCompleteInput">' +
                '<select data-ng-attr-size="{{selectSize}}" ng-show="options[\'{{attribute.oldValue.path}}\']" class="form-control autocomplete" ng-model="attribute.newValue.option" ng-click="defaultValue()" ng-change="changedValue()" ng-options="option as option.name for option in options[\'{{attribute.oldValue.path}}\'] track by option.value"></select>' +
                '</div>',
            scope: {
              attribute:'=',
              opId:'=',
              itemId:'='
            },

            link: function (scope, element, attrs) {
                var timer = false;
                scope.$watch("autoCompleteInput", function (newValue, oldValue) {
                    if (timer) {
                        $timeout.cancel(timer)
                    }
                    timer = $timeout(function () {
                    if (newValue !=oldValue) {
                            if (newValue.length <1) {
                                scope.options = undefined;
                            }
                            if (!scope.attribute || !scope.attribute.newValue || !scope.attribute.newValue.option || scope.attribute.newValue.option.name != newValue) {
                                //check if more than 2 characters entered, if so call operation options factory, passing input so far as parameter called partial
                                if (newValue.length >= 2) {
                                    scope.partial = newValue;
                                    populateAutoComplete(scope, attrs.autocompleteOptions, attrs.targetId);

                                    if (scope.attribute && scope.attribute.newValue && scope.attribute.newValue.option && scope.attribute.newValue.option.name) {
                                        scope.attribute.newValue.option.name = "";
                                    }
                                } //set previously selected option back to empty so that new option can be chosen
                            } else {
                                scope.options = undefined;
                            }
                        }
                        }, 500)
                });

                scope.changedValue = function () {
                    if (scope.attribute.newValue.option)
                    {
                        $log.debug('option selected, not default first option');
//if a value selected, then revert back to an input field with that value displayed
                        scope.autoCompleteInput = scope.attribute.newValue.option.name;
                        scope.partial = null;
                        scope.options = undefined;

                    }
                };

                scope.defaultValue = function () {   /* this is used when the first (default) value is selected, even if there are many options) */
                    if (scope.attribute.newValue.option)
                    {
                        $log.debug('default first option selected');
//if a value selected, then revert back to an input field with that value displayed
                        scope.autoCompleteInput = scope.attribute.newValue.option.name;
                        scope.partial = null;
                        scope.options = undefined;
                    }
                };
               }
            }
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('buttonConfirm', ['AppConstants', 'Utils', '$log', function (AppConstants, Utils, $log) {
    return {
        template:'<div ng-show="isOperationSupported()" ng-class="{\'action-btn pull-right\' : item && mobile != \'true\', \'btn-group dropup pull-right\' : !item && mobile !=\'true\', \'spacer10\':hasAction(\'score\')&&mobile}">'+
            '<button class="btn btn-primary button" ng-class="mobile == \'true\' ? \'btn-stacked\' : \'\'" type="button" style="text-decoration: none;font-weight: bold;" '+
            'confirmed-click="$event.stopPropagation();doOperationOnItem();" confirm-dialog-box ="{{\'fHCM2__Global_Are_You_Sure\'  | translate | suppress}}"'+
            'data-dismiss="modal">'+
            '<span class="badge pull-right" ng-show="hasAction()">1</span>'+
            '{{label  | translate | suppress}}</button>'+
            '</div>',
        restrict: 'EA',
        replace: true,
        scope: {
            operationId:'@operationId',
            label:'@label',
            item:'=item',
            processItem:'=processItem',
            teamMemberId:'@teamMemberId',
            mobile:'@mobile'
        },
        link: function (scope, element, attrs) {
            scope.isOperationSupported = function () {
                return scope.$parent.isOperationSupported(scope.item ? scope.item : scope.processItem, scope.operationId);
            }

            scope.doOperationOnItem = function () {
                if (scope.item) {
                    return scope.$parent.doOperationOnItem(scope.operationId, null, scope.item, null, scope.teamMemberId);
                } else {
                    //$log.error('doOperation not supported on process');
                    var refresh;
                    angular.forEach(scope.processItem.operations, function (operation) {
                        if (operation.id == scope.operationId) {
                            refresh = operation.refresh;
                        }
                    });

                    if (!refresh) {
                        $log.error('no operation found');
                        return;
                    }

                    return scope.$parent.doOperation(scope.operationId, null, null, null, refresh, scope.teamMemberId);
                }
            }

            scope.hasAction = function () {
                return scope.$parent.hasAction(scope.operationId, scope.item ? scope.item.id : undefined);
            }
        }
    };
}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('buttonOpen', ['AppConstants', 'Utils', '$log', function (AppConstants, Utils, $log) {
    return {
        template:'<div ng-show="isOperationSupported()" ng-class="{\'action-btn pull-right\' : item && mobile != \'true\', \'btn-group dropup pull-right\' : !item && mobile !=\'true\', \'spacer10\':hasAction(\'score\')&&mobile}">'+
            '<button class="btn btn-primary button" ng-class="{\'title-in-detail\': processItem.showTitleInDetail, \'btn-stacked\' : mobile == \'true\'}" type="button" style="text-decoration: none;font-weight: bold;" '+
            'ng-click="open(); $event.stopPropagation()" '+
            'data-dismiss="modal">'+
            '<span class="badge pull-right" ng-show="hasAction()">1</span>'+
            '{{label  | translate | suppress}}</button>'+
            '</div>',
        restrict: 'EA',
        replace: true,
        scope: {
            operationId:'@operationId',
            label:'@label',
            item:'=item',
            processItem:'=processItem',
            teamMemberId:'@teamMemberId',
            teamMemberName:'@teamMemberName',
            mobile:'@mobile',
            iframeItem:'@iframeItem'
        },
        link: function (scope, element, attrs) {
            scope.isOperationSupported = function () {
                return scope.$parent.isOperationSupported(scope.item ? scope.item : scope.processItem, scope.operationId);
            }
            scope.open = function () {

                var teamMember;
                if (scope.teamMemberId) {
                    teamMember = {name: scope.teamMemberName, id: scope.teamMemberId};
                }
                if(scope.iframeItem){
                  if (scope.item) {
                    return scope.$parent.openFrame({dataId: scope.operationId, item: scope.item}, null, teamMember);
                  }else{
                    return scope.$parent.openFrame({dataId: scope.operationId}, null, teamMember);
                  }
                }else{
                  if (scope.item) {
                    return scope.$parent.open({dataId: scope.operationId, item: scope.item}, null, teamMember);
                  } else {
                    return scope.$parent.open({dataId: scope.operationId}, null, teamMember);
                  }
                }
            }

            scope.hasAction = function () {
                return scope.$parent.hasAction(scope.operationId, scope.item ? scope.item.id : undefined);
            }
        }
    };
}]);

/* EOF */
/**
 * Created by CarolineR on 16/07/2015.
 */

'use strict';

angular.module('fairsailWX')

    .directive('colorConvert', ['$log', function ($log) {

        return {
            restrict: 'A',
            link: function link(scope, element, attrs) {
              scope.$watch(attrs.colorConvert, function(newVal, oldVal) {
                if (newVal) {
                  scope.colorConvert = JSON.parse(attrs.colorConvert);
                  scope.convertedColor = 'rgb(' +scope.colorConvert.red+ ',' +scope.colorConvert.green+ ',' +scope.colorConvert.blue+ ')';
                }
              });
            }
        }
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('confirmDialogBox', ['$modal', '$log', 'AppConstants',
        function($modal, $log, AppConstants){
            return {
                scope:{
                    msg:'@confirmDialogBox',
                    overrideMethod:'&',
                    overrideObject:'=',
                    overrideKey:'@'
                },
                link: function (scope, element, attr) {
                    scope.open = function (event) {
                        $log.log('open confirm modal');

                        scope.confirmationMessage = scope.msg ? scope.msg : ' ';

                        // get the translated msg
                        if (scope.overrideMethod && scope.overrideObject && scope.overrideKey) {
                            scope.confirmationMessage = scope.overrideMethod({processOrItem:scope.overrideObject, operationId: scope.overrideKey, defaultMsg: scope.confirmationMessage});
                            $log.log('messaged changed to ' + scope.confirmationMessage);
                        }

                        scope.modalInstance = $modal.open({
                            templateUrl: AppConstants.CONFIRMDIALOGVIEWSHTML,
                            backdrop: 'static',
                            controller: 'ConfirmDialogCtrl',
                            resolve: {
								modalParams: function () {
									return {
										message: scope.confirmationMessage,
										detail: scope.detailMessage,
										clickAction: attr.confirmedClick,
										operationScope: scope.$parent
									};
								}
                           }
                        });

                        scope.modalInstance.result.then(function () {
                            $log.info('Modal dismissed at: ' + new Date());
                        });
                    };

                    element.bind('click', scope.open);
                }
            };
        }]);


/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('constantsDirective', ['$log', 'AppConstants', function ( $log, AppConstants) {
    return {
      restrict: 'A',
		scope: {
			scopeProperty: "="
		},
        link: function (scope, element, attrs) {
            scope.scopeProperty = AppConstants[attrs.constKey];
        }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.directive('contactDetailsFieldSet', ['AppConstants', 'Utils', function (AppConstants, Utils) {
		return {
			templateUrl:AppConstants.CONTACTDETAILSFIELDSETVIEWSHTML,
			restrict: 'EA',
			scope: {
				fieldSet:'=contactDetailsFieldSet'
			},
			link: function (scope, element, attrs) {

				scope.$watch('fieldSet', function (newVal, oldVal) {
					if (newVal) {
						scope.orderedFieldSet = Utils.orderFieldSet(newVal);
						angular.forEach(scope.orderedFieldSet, function (field) {
							if (field.path == 'fHCM2__Mobile_Number__c' || field.path == 'fHCM2__Phone_Number__c') {
								field.type = 'PHONE';
							}
						});
					}
				});
			}
		};
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('cropImage', ['$timeout', '$compile', function ($timeout, $compile) {

        return {
            restrict: 'E',
            scope: {
                maxWidth: '=',
                maxHeight: '=',
                picUrl: '=',
                borderSize: '='
            },
            transclude:true,
            replace: true,
            template: '<span ng-style="{\'width\': setWidth, \'height\': setHeight, \'overflow\': \'hidden\', \'display\': \'inline-block\', \'vertical-align\': \'middle\', \'position\': \'relative\', \'border\': setBorderSize, \'border-radius\': \'50%\', \'background-color\': \'#FFFFFF\'}">'+
                '<img  id="myImage" ng-src="{{setPicUrl}}" src="{{setPicUrl}}" my-src="{{setPicUrl}}" ng-style="{\'display\': setDisplay, \'width\': setWidth, \'top\': \'0px\', \'left\': \'-1px\', \'position\': setPosition }">'+
                '</span>',

            compile: function(element, attrs)  {

                return {
                    pre: function(scope, element, attrs, controller, transcludeFn){
                        scope.$watch('picUrl', function (newVal, oldVal) {
                                if (!newVal) {
                                    return;
                                }
                        $timeout(function () {

                            scope.setWidth = scope.maxWidth + 'px';
                            scope.setHeight = scope.maxHeight + 'px';
                            scope.setPicUrl = scope.picUrl;
                            scope.setBorderSize = scope.borderSize + 'px solid #FFFFFF';
                            scope.setPosition = 'relative';
                            scope.setDisplay = 'block';
                        }, 0);
                        }, true);

                    },
                    post: function(scope, element, attrs, controller, transcludeFn){

                        scope.$watch('picUrl', function (newVal, oldVal) {
                            if (!newVal) {
                                return;
                            }
                            $timeout(function () {
                        var myEl = angular.element( document.querySelector( '#myImage' ) );
                                var myEl = ($('#myImage'));
                                scope.setWidth = scope.maxWidth + 'px';
                               scope.setHeight = scope.maxHeight + 'px';
                                scope.setPicUrl = scope.picUrl;
                                scope.setBorderSize = scope.borderSize + 'px solid #FFFFFF';
                                scope.setPosition = 'relative';
                                scope.setDisplay = 'block';
                                var myTop = (100 - myEl.height())/2;
                                scope.setImgTop = myTop + 'px';
                                var jsMyTop = myTop + 'px';

                                if(myTop>0)  {
                                    myEl.css({top: '0px'});
                                } else {
                                    myEl.css({top: jsMyTop});
                                }


                            }, 3000);
                        }, true);

                    }
                }

            }

        };
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .config(['datepickerConfig', function(datepickerConfig) {
       // datepickerConfig.startingDay= 0;
        datepickerConfig.showWeeks = true;
        //datepickerPopupConfig.toggleWeeksText = null;


    }])

    .directive('datepickerDirective', ['AppConstants', '$filter', 'ContextFactory','$timeout', '$locale', 'Utils', function (AppConstants, $filter, ContextFactory, $timeout, $locale, Utils) {
        return {
            require: '?ngModel',
            restrict: 'EA',
            scope: {
                'modelValue': '=date',
                'requiredField':'=dateRequired',
                'quartersList':'=isQuarter'


            },
            controller: function($scope, $element, $attrs) {

                // Store the current locale ID in a variable
                $scope.localeDateFormat = $locale.DATETIME_FORMATS.shortDate;

				$scope.displayLocaleDateFormat = Utils.userFriendlyDateFormat($scope.localeDateFormat);

                $scope.teamMember = ContextFactory.teamMember;

                $scope.$watch("opened",function(newValue,oldValue) {
                        if (!newValue) {
                            $scope.modelValue=$filter('date')($scope.modelValue,'yyyy-MM-dd');
                        }

                        });

                $scope.isMobile = function () {
                    if (navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/BlackBerry/i) || navigator.userAgent.match(/iPhone|iPad|iPod/i) || navigator.userAgent.match(/Opera Mini/i) || navigator.userAgent.match(/IEMobile/i)) {
                        return true;
                    } else {
                        return false;
                    }
                };
                $scope.open = function($event) {
                    $event.preventDefault();
                    $event.stopPropagation();

                    $scope.opened = true;
                };
                $scope.dateToString = function (date) {
                    if (angular.isDate(date)) {
                        return $filter('date')(date, 'yyyy-MM-dd');
                    } else {
                        return date;
                    }
                };
                $scope.setFocus = function () {
                    $element.focus();
                };


                // $scope.numRows = $templateCache.rows;
                $scope.StartQ1 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.sq1,'yyyy-MM-dd');
                };
                $scope.StartQ2 = function () {
                    $scope.modelValue=$filter('date')($scope.teamMember.sq2,'yyyy-MM-dd');
                };
                $scope.StartQ3 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.sq3,'yyyy-MM-dd');
                };
                $scope.StartQ4 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.sq4,'yyyy-MM-dd');
                };
                $scope.EndQ1 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.eq1,'yyyy-MM-dd');
                };
                $scope.EndQ2 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.eq2,'yyyy-MM-dd');
                };
                $scope.EndQ3 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.eq3,'yyyy-MM-dd');
                };
                $scope.EndQ4 = function () {
                     $scope.modelValue=$filter('date')($scope.teamMember.eq4,'yyyy-MM-dd');
                };

                            },
            templateUrl: AppConstants.DATEPICKERVIEWSHTML
        };
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('formatteddate', ['$filter', 'dateFilter','$locale', function ($filter, dateFilter, $locale) {

    return {
      restrict: 'A',
      require: 'ngModel',
      link: function (scope, element, attrs, ngModel) {

        var date = new Date();
        var minDate = date.getFullYear() - 80;
        var separator;
        var finalYear;
        scope.localeDateFormat = $locale.DATETIME_FORMATS.shortDate;

        scope.onBlur = function (e) {
          // the value is an object if date has been changed! Otherwise it was set as a string.
          if (typeof ngModel.$viewValue === "object") {
            element.context.value = isNaN(ngModel.$viewValue) ? "" : dateFilter(ngModel.$viewValue, scope.localeDateFormat);
            if (element.context.value === "") ngModel.$setValidity('required', false);
          }
        };

        ngModel.$parsers.push(function (viewValue) {
          var newDate = ngModel.$viewValue;
          var date = null;
          // pass through if we clicked date from popup
          if (typeof newDate === "object" || newDate === "") return newDate;

          if (scope.localeDateFormat.indexOf('/') > -1) {
            separator = '/';
          } else if (scope.localeDateFormat.indexOf('.') > -1) {
            separator = '.';
          } else if (scope.localeDateFormat.indexOf('-') > -1) {
            separator = '-';
          }

          var map = scope.localeDateFormat.split(separator);

          //search the position of the day,month and year in the array
          //so we can build the correct date
          for (var i = 0; i < map.length; i++) {
            if (map[i].toLowerCase().indexOf('m') > -1) {
              var m = i;
            } else if (map[i].toLowerCase().indexOf('d') > -1) {
              var d = i;
            } else if (map[i].toLowerCase().indexOf('y') > -1) {
              var y = i;
            }
          }

          var val = $filter('date')(element.val(), 'yyyy-MM-dd');

          var dateStr = $filter('date')(val, scope.localeDateFormat);

          if (dateStr === undefined)
            return element.html(ngModel.$viewValue || '');

          //var parsed = element.html(ngModel.$viewValue || '');

          var dateParts = dateStr.split(separator);

          //Date based in the array
          if (dateParts[y] !== undefined) {

            if (dateParts[y].length > 2) {
              finalYear = dateParts[y];
            } else {
              var currentMinDate = '19' + dateParts[y];
              var currentMaxDate = '20' + dateParts[y];

              if (currentMinDate.valueOf() >= minDate.valueOf()) {
                finalYear = currentMinDate;
              } else {
                finalYear = currentMaxDate;
              }
            }
          }

          var parsed = new Date(finalYear, dateParts[m] - 1, dateParts[d]);

          if (isNaN(parsed) === false) {
            ngModel.$setValidity('date', true);
          }

          return parsed ? parsed : viewValue;

        });
      }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('displayMode', ['$window', '$timeout', 'Utils', function ($window, $timeout, Utils) {
        return {
            restrict: 'A',
            scope: {
                displayMode: '='
            },
            template: '<span class="mobile"></span><span class="tablet"></span><span class="tablet-landscape"></span><span class="laptop"></span><span class="desktop"></span>',
            link: function(scope, elem, attrs) {
                var markers = elem.find('span');

                function update() {
                    angular.forEach(markers, function (element) {
                        if (Utils.isVisible(element)) {
                            scope.displayMode = element.className;
                            return false;
                        }
                    });
                }

                var t;
                angular.element($window).bind('resize', function() {
                    $timeout.cancel(t);
                    t = $timeout(function() {
                        update();
                        scope.$apply();
                    }, 300);
                });

                update();
            }
        };
    }]);


/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('editFieldSet', ['AppConstants', 'Utils', function (AppConstants, Utils) {
    return {
        templateUrl:AppConstants.EDITFIELDSETVIEWSHTML,
      restrict: 'EA',
        scope: {
            editFieldSet:'=editFieldSet',
            popDrop:'&',
            options:'='
        },
      link: function (scope, element, attrs) {
          if (attrs.emptyLabel) {
              scope.emptyLabel = attrs.emptyLabel;
          } else {
              scope.emptyLabel = "N/A"
          }

          scope.gated = attrs.gated ? true : false;

          scope.$watch('editFieldSet', function (newVal, oldVal) {
              if (newVal) {
                  scope.orderedFieldSet = Utils.orderFieldSet(newVal);
              }
          });

          scope.populateDropdown = function(fieldId, targetId) {
              scope.popDrop({fieldId:fieldId, targetId:targetId});
          }
       }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('errorsDirective', ['AppConstants', '$log', function (AppConstants, $log) {

        return {
			templateUrl:AppConstants.ERRORSVIEWSHTML,
            restrict: 'EA',
            link: function postLink(scope, element, attrs) {
				scope.hasFields = function (key) {
					if (scope.errors && scope.errors[key]) {
						var found = false;
						angular.forEach(scope.errors[key], function (error) {
							if (error.fieldId) {
								found = true;
							}
						});
					}

					return found;
				}
            }
        };
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('fieldSet', ['AppConstants', 'Utils', function (AppConstants, Utils) {
    return {
        templateUrl:AppConstants.FIELDSETVIEWSHTML,
        //template:'<div></div>',
      restrict: 'EA',
      scope: {
          fieldSet:'=fieldSet'
        },
      link: function (scope, element, attrs) {

          if (attrs.emptyLabel) {
              scope.emptyLabel = attrs.emptyLabel;
          } else {
              scope.emptyLabel = "N/A"
          }

          var fieldSetColumns;
          if (attrs.numberOfColumns) {
              fieldSetColumns = parseInt(attrs.numberOfColumns);
          } else {
              fieldSetColumns = 1;
          }

          switch (fieldSetColumns) {
              case 2:
                  scope.twoColumn = true;
                  break;
              case 0:
              case 1:
              default:
                  scope.oneColumn = true;
                  break;

          }

          if (attrs.useSeparators) {
              scope.useSeparators = true;
          } else {
              scope.useSeparators = false;
          }

          scope.$watch('fieldSet', function (newVal, oldVal) {
              if (newVal) {
                  scope.orderedFieldSet = Utils.orderFieldSet(newVal);
              }
          });
       }
    };
  }]);

/* EOF */
'use strict';

/**
 * Directive to handle the fieldset in a dynamic table
 */

angular.module('fairsailWX')
  .directive('fieldSetTable', ['AppConstants', 'Utils',  '$log', '$routeParams', 'ProcessDataFactory', 'ContextFactory', function (AppConstants, Utils, $log, $routeParams, ProcessDataFactory, ContextFactory) {
    return {
      template: '<tr ng-include src="getTemplateUrl()" />',
      restrict: 'EA',
      replace: true,
      scope: {
        item:'=item',
        processItem:'=processItem',
        fieldSetTable: '=fieldSetTable',
        mobile: '@'
      },
      link: function (scope, element, attrs) {

        /* if static column heading to be added to the table, eg. for created date */
        if (attrs.staticHeading) {
          scope.staticHeading = true;
          scope.staticTdType = attrs.staticTdType;
          scope.staticTdValue = attrs.staticTdValue;
        }

        /* if attachment column heading should be shown, set number of attachments on the scope */
        if (attrs.attachments) {
          scope.numAttachments = scope.item.numberOfAttachments;
          scope.showAttachments = true;
        }


        /**
         * Checks if it's mobile or not
         * 2 templates, one for the mobile view, another for the desktop view
         * @returns HTML page
         */
        scope.getTemplateUrl = function () {
          if (scope.mobile === 'true') {
            return AppConstants.FIELDSETTABLEMOBILEVIEWSHTML;
          } else {
            return AppConstants.FIELDSETTABLEVIEWSHTML;
          }
        }

        /**
         * Watch for the data
         * Images for collape/expand buttons
         */
        scope.$watch('fieldSetTable', function (newVal, oldVal) {
          if (newVal) {
            scope.imageCollapse = AppConstants.COLLAPSECONTACTGREYIMGSRC;
            scope.imageExpand = AppConstants.EXPANDCONTACTGREYIMGSRC;
            scope.orderedFieldSet = Utils.orderFieldSet(newVal);
          }
        });

        /**
         * Click event for View/Hide Details
         * The class hidden-row-table hides the details of the vacancy
         * Adds/removes class in order to hide/show
         */
        scope.showContent = function () {

          if (element.next().next().hasClass('hidden-row-table')) {

            if (attrs.requestDetails && !scope.item.full) {
              var teamMemberId;
              if (scope.teamMember && scope.teamMember.id) {
                teamMemberId = scope.teamMember.id;
              } else {
                teamMemberId = ContextFactory.teamMemberId
              }
              var deferredProcData = ProcessDataFactory.get({teamMemberId: teamMemberId, processId: $routeParams.processId, dataType: 'views', dataId: scope.processItem.detailViewName, itemId: scope.item.id});

              deferredProcData.$promise.then(function (data) {
                scope.item = data;
                scope.item.full = true;
              });
            }

            scope.expanded = true;
            element.next().next().removeClass('hidden-row-table');
          } else {
            scope.expanded = false;
            element.next().next().addClass('hidden-row-table');
          }
        }
      }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive("fileRead", ['$log', '$timeout', function ($log, $timeout) {
		return {
			scope: {
				fileRead: "=",
				uploadTooBig: "=",
				attachmentSelectorField: "="
			},
			link: function (scope, element, attributes, ctrl) {
				var maxFileSize;
				if (attributes.maxFileSize) {
					maxFileSize = parseInt(attributes.maxFileSize);

					if (!maxFileSize) {
						$log.error('Invalid max file size');
					}
				}

				scope.attachmentSelectorField = attributes.attachmentSelector;

				element.on("change", function (changeEvent) {
//					$log.debug('Changed: ' + JSON.stringify(changeEvent));
					scope.$apply(function () {
						if (element[0].files && element[0].files.length > 0) {
							$log.debug('found file' + element[0].files);
							scope.fileRead = element[0].files[0];

							if (scope.fileRead.size <= maxFileSize) {
								scope.uploadTooBig = false;
							} else {
								scope.uploadTooBig = true;
							}

						} else {
							$log.debug('no files selected in ' +  JSON.stringify(element[0]));

							scope.fileRead = undefined;
							scope.uploadTooBig = false;

						}
					});
				});
        element.on("click", function (changeEvent) {
          if (navigator.camera) {
            navigator.camera.getPicture(function(imageURI) {
                var f = new File;
                f.localURL = imageURI;
                f.name = imageURI.substr(imageURI.lastIndexOf('/')+1);
                f.type = "image/jpeg";
					$timeout(function() {
						scope.fileRead = f;
					}, 0);
              },
              function (message) {
                $log.debug('get picture failed');
              },
              {
                quality: 50,
                destinationType: navigator.camera.DestinationType.FILE_URI,
                sourceType: navigator.camera.PictureSourceType.PHOTOLIBRARY
              }
            );
          } else {
            return true;
          }
        });

      }
		}
	}]);

/* EOF */

'use strict';

angular.module('fairsailWX')

  .directive('fixpictureurl', [ 'FixPictureUrlFactory', function (FixPictureUrlFactory) {
    var fixpictureurl = {
      link: function postLink(scope, iElement, iAttrs) {
        iElement.bind('error', function() {
          FixPictureUrlFactory.fixsrc(angular.element(this));
        });
      }
    }
    return fixpictureurl;
  }]);

/* EOF */
/**
 * Created by CarolineR on 13/10/2014.
 */

'use strict';

angular.module('fairsailWX')
    .directive('hrRequest', ['Utils', function(Utils) {
        return {
            restrict: 'EA',
            scope: {
                oldFieldSets: '=',
                newFieldSets: '='
            },
            link: function (scope, element, attrs) {
                scope.$parent.combinedFieldSet = Utils.combineAllFieldSets(scope.oldFieldSets, scope.newFieldSets);

                angular.forEach (scope.$parent.combinedFieldSet, function(attribute) { //replace any empty old values with a -
                    if (attribute.oldValue.type=='PICKLIST' && (attribute.oldValue.option.value =='' || attribute.oldValue.option.value == undefined || attribute.oldValue.option.value == null)) {
                        attribute.oldValue.option.value = '-' ;
                    }
                    if (attribute.oldValue.type=='AUTOCOMPLETE' && (attribute.oldValue.option.name =='' || attribute.oldValue.option.name == undefined || attribute.oldValue.option.name == null)) {
                        attribute.oldValue.option.name = '-' ;
                    }
                    if ((attribute.oldValue.type!='PICKLIST' && attribute.oldValue.type!='AUTOCOMPLETE') && (attribute.oldValue.value =='' || attribute.oldValue.value == undefined || attribute.oldValue.value == null)) {
                        attribute.oldValue.value = '-' ;
                    }
                });
               }
            }
    }]);

/* EOF */
/**
 * Created by joshuaeze on 13/07/2015.
 */
'use strict';

angular.module('fairsailWX')
  .directive('ie9fileattachment', function () {

    return {
      restrict:"E",
      replace: true,
      //transclude:true,
      scope:{
        teamMemberId:'@teamMemberId',
        maxSize: '='
      },
      template:'<iframe  width="100%" height="60" frameborder="0" allowfullscreen scrolling="no" ng-src="{{\'/apex/AttachmentUpload?maxSize=\' + maxSize + \'&teammember=\'+ teamMemberId | trustAsResourceUrl }}"></iframe>'
    //  https://fhcm2.na1.visual.force.com
    }

});

/* EOF */
'use strict';

/*
*
* Directive to change the height of the iframe
* The directive receives a post message with the height  of the page
* from collaboration portal and updates the iframe height and process-views div
*
 */


angular.module('fairsailWX')
  .directive('iframeSetDimensionsOnload', ['Utils', function (Utils) {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        element.on('load', function () {

          var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
          var eventer = window[eventMethod];
          var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

          var listener = function (e) {

            //get post message from collaboration portal
            var postMessage = String(e.data);

            //search por "ResizeHeight" in the post message
            if (postMessage.indexOf("ResizeHeight") === 0) {

              //split the post message and use the second part as the height change
              var res = postMessage.split("-");
              if (res[0] == "ResizeHeight") {

                //change the height of the process-views container(processes container in WX)
                var processViewId = document.getElementById("process-views");
                if (processViewId != null) {
                  var newHeight = parseInt(res[1]) + 150;

                  //change the height of the iframe element
                  element.css('height', parseInt(res[1]) + 30);


                  processViewId.style.height = '0px';
                  processViewId.style.height = newHeight + 'px';

                }
              }
            }
          }

          eventer(messageEvent, listener, false);

        })
      }
    }
  }]);

/* EOF */

'use strict';

angular.module('fairsailWX')
.directive('isFieldsetValuesEmpty', ['$log', function ($log){
  return{
    restrict: 'EA',
	  replace: 'false',
    link: function(scope, element, attrs) {


        // set an isEmpty property on the fieldset object to true
        // go through the list of fields in the fieldset and check their values,
        // if there is a not null value in any of the fields in the fieldset,
        // set the isEmpty property of the fieldset to false and return.

        scope.$watch(function () {
			if (attrs.isFieldsetValuesEmpty) {
				var parts = attrs.isFieldsetValuesEmpty.split('.');
				var obj = scope[parts[0]];
				for (var i = 1; i < parts.length - 1; i++) {
					obj = obj[parts[i]];
				}
				if (obj && obj[parts[i]]) {
					return obj[parts[i]];
				}
			}

			return undefined;
		}, function(newVal, oldval){

          if(newVal) {

            newVal.isEmpty = true;

            angular.forEach(newVal.valueAttributes, function(value){
                if(value.value != null){
                    newVal.isEmpty = false;
                    return;
                }
            });

            //if the isEmpty field is still true
            if(newVal.isEmpty) {
              angular.forEach(newVal.optionAttributes, function (value) {
                if (value.value != null) {
                  newVal.isEmpty = false;
                  return;
                }
              });
            }

            //$log.debug("\n\nName of the fieldset : " + newVal.name + "\n" + JSON.stringify(newVal) + "\n\n");
          }

        });
    }
  };
}]);

/* EOF */
/**
 * Created by CarolineR on 11/11/2014.
 */

'use strict';

angular.module('fairsailWX')

    .directive('itemData', [ function () {
        return {
            scope: {
                item: '=currentItem',
                itemOpen: '=itemOpen',
                processItem: '=processItem'
            },
            restrict: 'EA',
            controller: 'ListItemCtrl'
        }
    }]);
/* EOF */
'use strict';

/*
*
* Directive to create a link to a profile page
* Needs team-member-id in the element to get team member id
*
 */

angular.module('fairsailWX')
  .directive('linkProfile', ['ContextFactory', function (ContextFactory) {
    return {
      restrict: 'A',
      scope: {
        teamMemberId: '@teamMemberId'
      },
      link: function (scope, element, attrs) {

        //Click event?
        element.on('click', function () {
          ContextFactory.selectTeamMember(attrs.teamMemberId, true, true);
        })
      }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('loadTeam', ['$routeParams', 'ContextFactory', function ($routeParams, ContextFactory) {
        return {
            restrict: 'EA',
            link: function postLink(scope, element, attrs) {
                    // put team onto $scope
                    if ($routeParams.teamName) {
                        scope.teamName = $routeParams.teamName;
                        scope.teamMember = ContextFactory.teamMember;
                        scope.teamMembers = ContextFactory.getTeamMembers(attrs.teamName);
					}
            }
        }
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('mobileServiceBar', ['AppConstants', '$log', function (AppConstants, $log) {
        return {
            templateUrl:AppConstants.MOBILESERVICEBARVIEWSHTML,
            restrict: 'EA',
            link: function postLink(scope, element, attrs) {
				$log.debug('Linking mobileServiceBar Directive');

                scope.openExtraStatus = false;

				scope.setYourPathAccordion = function(catItemId){         // close extra menu then go to selected sub-menu item
					scope.openExtraStatus = false;
					scope.setYourPath(catItemId);
				};

				scope.setYourOtherPathAccordion = function(path){         // close extra menu then go to selected item
					scope.openExtraStatus = false;
					scope.setYourOtherPath(path);
				};

				scope.setYourPathSubAccordion = function(catItemId, subNavItemId){         // close extra menu then go to selected sub-menu item
                    scope.openExtraStatus = false;
                    scope.setYourPathSub(catItemId, subNavItemId);
                };

                scope.toggleExtra = function () {
                    $log.debug(" toggling the category dropdown");
                    if(scope.openExtraStatus == false){
                        scope.openExtraStatus = true;
                    }else {
                        scope.openExtraStatus = false;
                    }
                };
            }
        };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('navigationDirective', ['AppConstants', function (AppConstants) {
    return {
      templateUrl:AppConstants.NAVIGATIONVIEWSHTML,
      controller: 'NavigationCtrl',
      restrict: 'EA',
      scope:{}
    };
  }]);

/* EOF */
/**
 * Created by CarolineR on 23/12/2014.
 */
'use strict';

angular.module('fairsailWX')
    .directive('objectivesProgress', [function () {
        return {
            restrict: 'EA',
            link: function link(scope, element, attrs) {
                scope.$watch('processItem.data', function (newVal, oldVal) {
                    if (!newVal) {
                        return;
                    }
                    var belowTrack = parseInt(attrs.progressBelowTrack);
                    var onTrack = parseInt(attrs.progressOnTrack);
                    var aboveTrack = parseInt(attrs.progressAboveTrack);
                     scope.progressTotal = belowTrack + onTrack + aboveTrack;
                    if (scope.progressTotal>0) {
                        scope.belowTrackPercentage = (100 * (belowTrack / scope.progressTotal)).toFixed(2);
                        scope.onTrackPercentage = (100 * (onTrack / scope.progressTotal)).toFixed(2);
                        scope.aboveTrackPercentage = (100 * (aboveTrack / scope.progressTotal)).toFixed(2);
                    }
                    else {
                        scope.belowTrackPercentage = 0;
                        scope.onTrackPercentage = 0;
                        scope.aboveTrackPercentage = 0;
                    }
                });
            }
        }
    }]);


/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('operationOptions', [function () {
        return {
            restrict: 'EA',
            link: function link(scope, element, attrs) {
                if (attrs.dependentFieldPath) {
						var parts = attrs.dependentFieldPath.split('.');
						var obj = scope[parts[0]];
						for (var i = 1; i < parts.length - 1; i++) {
							obj = obj[parts[i]];
						}
						if (obj && obj[parts[i]]) {
							var newVal = obj[parts[i]];
							var dependentFieldId = attrs.dependentFieldId ? attrs.dependentFieldId : attrs.dependentFieldPath;
							scope.populateDropdown(attrs.operationOptions, attrs.targetId, dependentFieldId, newVal.value ? newVal.value : newVal);
						}

                    scope.$watch(attrs.dependentFieldPath, function(newVal, oldVal) {
						// if value of dependent field cleared, clear this selection
                        if (oldVal && (oldVal.value != (newVal ? newVal.value : '')) && attrs.ngModel) {
                            var parts = attrs.ngModel.split('.');
                            var obj = scope[parts[0]];
                            for (var i = 1; i < parts.length - 1; i++) {
                                obj = obj[parts[i]];
                            }
                            if (obj[parts[i]]) {
                                obj[parts[i]] = {name: ''};
                            }
                        }
						// get options
                        if (newVal && ((!oldVal || oldVal.value != newVal.value) || !newVal.value)) {
                            var dependentFieldId = attrs.dependentFieldId ? attrs.dependentFieldId : attrs.dependentFieldPath;
                            scope.populateDropdown(attrs.operationOptions, attrs.targetId, dependentFieldId, newVal.value ? newVal.value : newVal);
                        }
                    });
                } else  {
					scope.populateDropdown(attrs.operationOptions, attrs.targetId);

					scope.$watch('data', function (newVal, oldVal) {
						if (newVal && newVal != oldVal) {
							scope.populateDropdown(attrs.operationOptions, attrs.targetId);
						}
					});
                }
            }
        };
    }]);

/* EOF */
/**
 * Created by CarolineR on 12/11/2015.
 */

'use strict';

angular.module('fairsailWX')

    .directive('orgchart', ['$log', 'AppConstants', function ($log, AppConstants) {
        var org;
		var fetchData = false;
        return {
            templateUrl:AppConstants.ORGCHARTSTRUCTUREVIEWSHTML,
            restrict: 'EA',
            scope:{
                org:"=orgchart" /* get or populate data once this is defined */
            },
            link: function link(scope, element, attrs) {
                fetchData = (attrs.fetchData == 'true'); /* if there isn't already data on the process scope, then fetch org chart data */
            },
            controller: ['$scope', '$modal', 'OrgChartFactory', '$routeParams', 'ContextFactory', 'ProcessDataFactory', 'Utils', '$log', function ($scope, $modal, OrgChartFactory, $routeParams, ContextFactory, ProcessDataFactory, Utils, $log) {

                function populateOrgChart(result) {
					if (!result) {
						$log.error('cant refresh without data');
						return;
					}
                    $scope.subject = result.person;

                    $scope.directReportRows = Utils.sortPeopleIntoColumns(result.person.directReports, $scope.displayMode);
                    $scope.crossReportRows = Utils.sortPeopleIntoColumns(result.person.crossReports, $scope.displayMode);
                    $scope.colleaguesRows = Utils.sortPeopleIntoColumns(result.person.colleagues, $scope.displayMode);

                    $scope.primaryManager = result.primaryManager;
                    $scope.crossReportManagers = result.crossReportManagers;

                    $scope.crossManagerRows = Utils.sortPeopleIntoColumns(result.crossReportManagers, $scope.displayMode);

                    $scope.columnStyle = Utils.getNumberOfPeopleColumnsAvailable($scope.displayMode);

                }

                function getOrgChart() {        /* get org chart data for original org chart and populate it */
                    var deferred = OrgChartFactory.get({teamMemberId: $routeParams.teamMemberId, level: '3'});
                    deferred.$promise.then(function (result) {
                        $scope.org = result;     /* save result to use in populateOrgChart() if display mode changes */
                        populateOrgChart(result);
                    });
                }

                $scope.AppConstants = AppConstants;

                $scope.countActions = function (teamMemberId) {
                    if($routeParams.categoryId && $routeParams.processId) {     /* only get actions if a process */
                        $log.debug('process');
                        return $scope.$parent.countActions(teamMemberId);
                    }
                };

                    $scope.setSubject = function (teamMemberId) {
                        $log.debug('in the set subject function');
                    if($routeParams.categoryId && $routeParams.processId) {
                        $log.debug('process');
                        ContextFactory.setYourPath(teamMemberId, $routeParams.categoryId, $routeParams.processId);      /* if a process */
                    }
                    else {
                        $log.debug('orgchart');
                        ContextFactory.setYourOtherPath(teamMemberId, 'orgchart');      /* if org chart */
                    }
                };

                $scope.$watch('org', function(value) { /* once org is defined, get OrgChart or just populate if data already exists */
                    $log.debug('fetchdata is ' + fetchData);
                        if (fetchData && !value) {
                            getOrgChart();
                        }
                        else
                        {
							if (value) {
								populateOrgChart(value);
							}
                        }
                });

                $scope.displayMode = ''; // default value

                $scope.$watch('displayMode', function(value) {
                    var refresh = true;
                    switch(value) {
                        case 'mobile':
                            // do stuff for mobile mode
                            break;
                        case 'tablet':
                            // do stuff for tablet mode
                            // and so on
                            break;
                        case 'tablet-landscape':
                            // do stuff for -landscape mode
                            // and so on
                            break;
                        case 'laptop':
                            // do stuff for laptop mode
                            // and so on
                            break;
                        case 'desktop':
                            // do stuff for desktop mode
                            // and so on
                            break;
                        default:
                            refresh = false;
                            break;
                    }

                    if (refresh && $scope.org) {
                        populateOrgChart($scope.org);
                    }
                });

            }]
        }
    }]);
/* EOF */
/**
 * Created by CarolineR on 09/10/2014.
 */

'use strict';

angular.module('fairsailWX')
    .directive('percentagebonusDirective', ['$log',
        function ($log) {
        return {
            restrict: 'E',
            replace: true,
            template:
                '<div>' +
                '<div class="form-field-clear">' +
                '<label>{{title}}: Amount</label>' +
                '<div class="pull-right modal-error-non-mobile currency" ng-show="formoptionalattributes.bonusamount.$dirty && formoptionalattributes.bonusamount.$error.pattern || formoptionalattributes.bonuspercent.$dirty && formoptionalattributes.bonuspercent.$error.pattern">' +
                '<span class="label modal-error" ng-show="formoptionalattributes.bonusamount.$error.pattern || formoptionalattributes.bonuspercent.$error.pattern">Invalid entry</span>' +
                '</div>' +
                '</div>' +
                '<div class="width-fieldset">{{attribute.oldValue.value}}</div>' +
                '<span><input class="currency-amount input-error" type="text" ng-model="bonusAmount" name="bonusamount"  ng-pattern="/^[0-9/.]*$/"></span>' +
                '<span>=</span>' +
                '<span><input class="currency-percentage input-error" type="text" ng-model="bonusPercentage" name="bonuspercent"  ng-pattern="/^[0-9/.]*$/"></span>' +
                '<span>{{label}}</span>' +
                '<div class="modal-error-mobile col-lg-6" ng-show="formoptionalattributes.bonusamount.$dirty && formoptionalattributes.bonusamount.$error.pattern || formoptionalattributes.bonuspercent.$dirty && formoptionalattributes.bonuspercent.$error.pattern">' +
                '<span class="modal-error" ng-show="formoptionalattributes.bonuspercent.$error.pattern || formoptionalattributes.bonusamount.$error.pattern">Invalid entry</span>' +
                '</div>' +
                '</div>',

            link: function (scope, element, attrs) {
                    angular.forEach (scope.combinedFieldSet, function(attribute) {
                            if (attribute.oldValue.path =='fHCM2__Salary__cDOTfHCM2__Amount__c') {
                                if (attribute.oldValue.value == "-") {
                                    scope.currentSalary = attribute.oldValue.value;
                                } else {
                                    scope.currentSalary = Number(attribute.oldValue.value);
                                }
                            }
                    });

                    scope.label="% of annual";
                    scope.title="Bonus";
                    scope.bonusPercentage = "";

				var tempBonusPercentage; // to prevent rounded percentage adjusting bonusAmount

                scope.$watch("bonusAmount",function(newValue,oldValue) {
					$log.debug('bonusAmount watch fired ' + newValue + ' : ' + oldValue);
                    if (newValue == oldValue) {
                        return;
                    }
                    if(newValue && !isNaN(scope.currentSalary)) {
						scope.bonusPercentage = round(100 * Number(newValue) / Number(scope.currentSalary), 2);

						tempBonusPercentage = 100 * (Number(newValue)) / Number(scope.currentSalary);

                        scope.attribute.newValue.value = newValue;
                    } else {
						$log.debug('clearing percentage');
                        scope.attribute.newValue.value = ""; //when a previously entered value is deleted
                        scope.bonusPercentage = "";
						tempBonusPercentage = 0;
                    }
                });

                scope.$watch("bonusPercentage",function(newValue,oldValue) {
					$log.debug('bonusPercentage watch fired ' + newValue + ' : ' + oldValue);

					if (newValue == oldValue) {
                        return;
                    }
					if (newValue && (!isNaN(scope.currentSalary))) {
						if (round(tempBonusPercentage, 2) != Number(newValue)) {
							scope.bonusAmount = round((Number(newValue) * Number(scope.currentSalary) / 100), 2);
						}
					} else {
						scope.attribute.newValue.value = ""; //when a previously entered value is deleted
						scope.bonusAmount = "";
					}
                });

                function round(value, decimals) {
                    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
                }

            }
        }
    }]);


/* EOF */
/**
 * Created by CarolineR on 09/10/2014.
 */

'use strict';

angular.module('fairsailWX')
    .directive('percentagesalaryDirective', ['$log',
        function ($log) {
        return {
            restrict: 'E',
            replace: true,
            template:
                '<div>' +
                '<div class="form-field-clear">' +
                '<label >{{title}}: Amount</label>' +
                '<div class="pull-right modal-error-non-mobile currency" ng-show="formoptionalattributes.salaryamount.$dirty && formoptionalattributes.salaryamount.$error.pattern || formoptionalattributes.salarypercent.$dirty && formoptionalattributes.salarypercent.$error.pattern">' +
                '<span class="label modal-error" ng-show="formoptionalattributes.salaryamount.$error.pattern || formoptionalattributes.salarypercent.$error.pattern">Invalid entry</span>' +
                '</div>' +
                '</div>' +
                '<div class="width-fieldset">{{currentSalary}}</div>' +
                '<span><input class="currency-amount input-error" type="text" ng-model="salaryAmount" name="salaryamount" ng-pattern="/^[0-9/.]*$/"></span>' +
                '<span>=</span>' +
                '<span><input class="currency-percentage input-error" type="text" ng-model="salaryPercentage" name="salarypercent" ng-pattern="/^(\-)?[0-9/.]*$/"></span>' +
                '<span >{{label}}</span>' +
                '<div class="modal-error-mobile col-lg-6" ng-show="formoptionalattributes.salaryamount.$dirty && formoptionalattributes.salaryamount.$error.pattern || formoptionalattributes.salarypercent.$dirty && formoptionalattributes.salarypercent.$error.pattern">' +
                '<span class="modal-error" ng-show="formoptionalattributes.salarypercent.$error.pattern || formoptionalattributes.salaryamount.$error.pattern">Invalid entry</span>' +
                '</div>' +
                '</div>',

            link: function (scope, element, attrs) {


                    scope.label="% increase";
                    scope.title="Salary";
                    scope.salaryAmount="";
                    scope.salaryPercentage ="";

                if (scope.attribute.oldValue.value == "-") {
                        scope.currentSalary = scope.attribute.oldValue.value;
                    } else {
                    scope.currentSalary = Number(scope.attribute.oldValue.value);
                }

                scope.$watch("salaryAmount",function(newValue,oldValue) {
                    if(newValue) {
                        if (!isNaN(scope.currentSalary)) {
                                scope.salaryPercentage = round(100 * (Number(newValue) - scope.currentSalary) / scope.currentSalary, 2);
                                scope.tempSalaryPercentage = 100 * (Number(newValue) - scope.currentSalary) / scope.currentSalary;
                        }
                        scope.attribute.newValue.value = newValue;
                    }
                    if(!newValue) {
                        scope.attribute.newValue.value = undefined; //when a previously entered value is deleted
                        scope.salaryPercentage = undefined;
                    }
                });

                scope.$watch("salaryPercentage",function(newValue,oldValue) {
                        if (newValue && (!isNaN(scope.currentSalary))) {
                            if (round(scope.tempSalaryPercentage, 2) != Number(newValue)) {
                                scope.salaryAmount = round(((scope.currentSalary * (Number(newValue)/ 100)) + scope.currentSalary), 2);
                                scope.attribute.newValue.value = newValue;
                            }
                        }
                    if(newValue==="") { /* only clear the salary amount if percentage cleared manually, not if calculation tends towards zero */
                        scope.attribute.newValue.value = undefined; /*when a previously entered value is deleted */
                        scope.salaryAmount = undefined;
                    }
                });

                function round(value, decimals) {
                    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
                }

            }
        }
    }]);


/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('pickadate', ['$locale', 'pickadateUtils', 'dateFilter', '$timeout', function($locale, pickadateUtils, dateFilter, $timeout) {
        return {
            require: 'ngModel',
            scope: {
                date: '=ngModel',
                defaultDate: '=',
                minDate: '=',
                maxDate: '=',
                setMonths: '=',
                allAbsences:'=',
                allCoyholidays: '=',
                dayoffDates: '=',
                vacationDates: '=',
                holidayDates: '=',
                weekendDates: '=',
                coyholidayDates: '=',
                dial: "&",
                changeyear: "&"
            },
            replace: true,
            template:
                '<div class="pickadate">' +
                    '<ul class="pager">'+
                        '<li class="previous"><a ng-click="changeyear({offset: prevYear})" ng-show="allowPrevYear">&larr; Previous</a></li>'+
                        '<li class="next"><a ng-click="changeyear({offset: nextYear})" ng-show="allowNextYear">Next &rarr;</a></li>'+
                    '</ul>'+
                    '<div class="row" ng-repeat="result in (12/3 | array)" style=" margin-right: 0px !important; margin-left: 0px !important;">'+
                        '<div class="col-lg-4 col-md-4" ng-repeat="m in myMonths.slice(3*$index, 3*$index + 3)" >'+
                            '<div class="pickadate-header">' +
                                '<h3 class="pickadate-centered-heading">' +
                                    '{{m.myCurrentDates | date:"MMMM yyyy"}}' +
                                '</h3>' +
                            '</div>' +
                            '<div class="pickadate-body">' +
                                '<div class="pickadate-main">' +
                                    '<ul class="pickadate-cell">' +
                                        '<li class="pickadate-head" ng-repeat="dayName in m.myDayNames">' +
                                            '{{dayName}}' +
                                        '</li>' +
                                    '</ul>' +
                                    '<ul class="pickadate-cell">' +
                                        '<li ng-repeat="d in m.myDates" ng-click="dial({selectedDate: d.date, selectedClass: d.className, selectedMode: \'desktop\'})" class="{{d.className}}" tooltip="{{d.tooltipMessage}}" ng-class="{\'pickadate-active\': date == d.date, \'pending\': d.myAbsenceStatus == \'Pending\', \'provisional\': d.myAbsenceStatus == \'Provisional\', \' \': d.myAbsenceStatus == \'Approved\'}">' +
                                            '{{d.date | date:"d"}}' +
                                        '</li>' +
                                    '</ul>' +
                                '</div>' +
                            '</div>'+
                        '</div>' +
                    '</div>' +
                '</div>',

            link: function(scope, element, attrs) {
                scope.$watch("minDate",function(newValue,oldValue) {
                    if (newValue) {
                        //This gets called when data changes.
                        var hello = function () {
//                    console.log('scope, element, attrs---------------------------------')
//                    console.log(scope, element, attrs);
//                    console.log('ngmodel---------------------------------')
                            //   console.log(ngModel);
                            var indexOf = [].indexOf || function (item) {
                                for (var i = 0, l = this.length; i < l; i++) {
                                    if (i in this && this[i] === item) return i;
                                }
                                return -1;
                            };

                            var minDate = scope.minDate && pickadateUtils.stringToDate(scope.minDate),
                                maxDate = scope.maxDate && pickadateUtils.stringToDate(scope.maxDate),
                                setMonths = scope.setMonths,
                                allAbsences = scope.allAbsences || [],
                                allCoyholidays = scope.allCoyholidays || [],
                                dayoffDates = scope.dayoffDates || [],
                                vacationDates = scope.vacationDates || [],
                                holidayDates = scope.holidayDates || [],
                                weekendDates = scope.weekendDates || [],
                                coyholidayDates = scope.coyholidayDates || [],
                               currentDate = new Date(scope.minDate).toDateString();


                            scope.dayNames = $locale.DATETIME_FORMATS['SHORTDAY'];
                            scope.currentDate = currentDate;
                            //scope.t           = i18n.t;
                            scope.myMonths = [];

                            scope.myRender = function (initialDate) {
                                initialDate = new Date(initialDate.getFullYear(), initialDate.getMonth(), 1, 3);
                                var currentMonth = initialDate.getMonth() + 1,
                                    dayCount = new Date(initialDate.getFullYear(), initialDate.getMonth() + 1, 0, 3).getDate(),
                                    prevDates = pickadateUtils.dateRange(-initialDate.getDay(), 0, initialDate),
                                    currentMonthDates = pickadateUtils.dateRange(0, dayCount, initialDate),
                                    lastDate = pickadateUtils.stringToDate(currentMonthDates[currentMonthDates.length - 1]),
                                    nextMonthDates = pickadateUtils.dateRange(1, 7 - lastDate.getDay(), lastDate),
                                    allDates = prevDates.concat(currentMonthDates, nextMonthDates),
                                    dates = [],
                                    today = dateFilter(new Date(), 'yyyy-MM-dd');


                                // Add an extra row if needed to make the calendar to have 6 rows

                                if (allDates.length / 7 < 6) {
                                    allDates = allDates.concat(pickadateUtils.dateRange(1, 8, allDates[allDates.length - 1]));
                                }


                                for (var i = 0; i < allDates.length; i++) {
                                    var className = "", tooltipMessage = "", myTooltipMessage = "", myAbsenceStatus = "", date = allDates[i];
                                    var wkd = new Date(date);
                                    // console.log('ddate ============================> ' + wkd);
                                    if (dateFilter(date, 'M') !== currentMonth.toString()) {
                                        className = 'pickadate-disabled';
                                        //className = 'pickadate-enabled';
                                    } else if (indexOf.call(dayoffDates, date) >= 0) {
                                        className = 'pickadate-enabled pickadate-dayoff';
                                        angular.forEach(allAbsences, function (thisDate) {
                                            if (thisDate.myDate === date) {
                                                myTooltipMessage = thisDate.myReason;
                                                myAbsenceStatus = thisDate.myStatus;
                                            }
                                        });
                                        tooltipMessage = myTooltipMessage;

                                    } else if (indexOf.call(vacationDates, date) >= 0) {
                                        className = 'pickadate-enabled pickadate-vacation';
                                    } else if (indexOf.call(holidayDates, date) >= 0) {
                                        //console.log('dates holiday = '+date)
                                        className = 'pickadate-enabled pickadate-holiday';
                                        angular.forEach(allAbsences, function (thisDate) {
                                            if (thisDate.myDate === date) {
                                                myTooltipMessage = thisDate.myReason;
                                                myAbsenceStatus = thisDate.myStatus;
                                            }
                                        });
                                        tooltipMessage = myTooltipMessage;
                                    } else if (indexOf.call(coyholidayDates, date) >= 0) {
                                        //console.log('dates holiday = '+date)
                                        className = 'pickadate-enabled pickadate-coyholiday';
                                        angular.forEach(allCoyholidays, function (thisDate) {
                                            if (thisDate.myDate === date) {
                                                myTooltipMessage = thisDate.myLabel;
                                                myAbsenceStatus = thisDate.myStatus;
                                            }
                                        });
                                        tooltipMessage = myTooltipMessage;
                                    } else if (indexOf.call(weekendDates, date) >= 0)
                                        className = 'pickadate-disabled pickadate-weekend';
                                    else {
                                        className = 'pickadate-enabled';
                                    }

                                    if (date === today) {
                                        className += ' pickadate-today';
                                    }

                                    dates.push({date: moment(date).format('YYYY-MM-DD'), className: className, tooltipMessage: tooltipMessage, myAbsenceStatus: myAbsenceStatus});
                                    //console.log('date.toDateString()=================))))))))))))))))))))))))))))::::::::::::::::::::'+new Date(date).toDateString())

                                }

                                return dates
                            };

                            // ngModel.$render = function () {
                            scope.$watch(attrs.ngModel, function (newVal, oldVal) {
                                if (!newVal) {
                                    return;
                                }
                                // console.log('first call current date = ' + setMonths);
                                scope.myMonths = [];
                                for (var i = 0; i < setMonths; i++) {
                                   // var dcurrentDate = new Date(currentDate);
                                    var d = new Date(minDate);
                                    d.setDate(1);
                                    d.setMonth(d.getMonth() + i);

                                    scope.myMonths.push({myCurrentDates: d, myDayNames: scope.dayNames, myDates: scope.myRender(d)});
                                }
//                         console.log('d ============================> ' + d);
//                         console.log('d timezone ============================> ' + d.getTimezoneOffset()/60);
//                        console.log('currentDate ============================> ' + currentDate);

                                var nextYearInitialDate = new Date(minDate);
                                var currentYear = nextYearInitialDate.getFullYear();
                                var d = new Date(minDate);
                                scope.nextYear = d.getFullYear() + 1;
                                scope.prevYear = d.getFullYear() - 1;
                                scope.allowPrevYear = true;
                                scope.allowNextYear = true;


                            });

                            }
                        $timeout(function () {
                            hello();
                        }, 0);
                        // $timeout (hello,0);
                    }
            });
        }



        };
    }]);





/* EOF */
/**
 * Created by joshuaeze on 11/06/2015.
 */
'use strict';

angular.module('fairsailWX')
  .directive('printOrgChartFieldSet', ['AppConstants', 'Utils', function (AppConstants, Utils) {
    return {
      templateUrl:AppConstants.PRINTABLEORGCHARTFIELDSETVIEWSHTML,
      restrict: 'EA',
      scope: {
        fieldSet:'=printOrgChartFieldSet'
      },
      link: function (scope, element, attrs) {

        scope.$watch('fieldSet', function (newVal, oldVal) {
          if (newVal) {
            scope.orderedFieldSet = Utils.orderFieldSet(newVal);
            angular.forEach(scope.orderedFieldSet, function (field) {
              if (field.path == 'fHCM2__Mobile_Number__c' || field.path == 'fHCM2__Phone_Number__c') {
                field.type = 'PHONE';
              }
            });
          }
        });
      }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('processDetailsTab', ['AppConstants', '$routeParams', '$location', function (AppConstants, $routeParams, $location) {
    var currentTab = 1;

    return {
      restrict: 'EA',
      link: function postLink(scope, element, attrs) {
        scope.isSet = function(checkTab) {
          return currentTab == checkTab;
        };

        scope.setTab = function(setTab) {
          currentTab = setTab;
        };

        if (attrs.processDetailsTab && attrs.openTab && parseInt(attrs.openTab) != NaN) {
          // put team onto $scope
            if ($routeParams.source == attrs.processDetailsTab) {
              scope.setTab(parseInt(attrs.openTab));

              $location.url($location.path());
            }
        } else {
          scope.setTab(1);

        }
      }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
	.directive('refreshOnChange', [function () {

		function itemChanged(scope, field) {
			var params = {dataId: scope.opId};
			params[field] = scope.data[field].value;
			scope.$parent.refreshOperationData(params);
		};

		return {
			restrict: 'EA',
			link: function (scope, element, attrs) {

				scope.$watch(function () {
					return scope.data[attrs.changedItem];
				}, function (newVal, oldVal) {
					if (newVal && (!oldVal || oldVal.value != newVal.value)) {
						itemChanged(scope, attrs.changedItem);
					}
				})

			}
		}
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('refreshOnDateRangeChange', [function () {

    function datesChanged(opId, scope) {
      if (scope.data.startDate && scope.data.endDate) {
        if (scope.errors && scope.errors.errors) {
            scope.errors.errors = undefined;
        }
        var params = {dataId: opId, startDate: scope.data.startDate, endDate: scope.data.endDate, reason: scope.data.reason ? scope.data.reason.value : undefined};
        scope.$parent.refreshOperationData(params);
      }
    };

        return {
            restrict: 'EA',
            link: function (scope, element, attrs) {

              scope.$watch('data.endDate', function (newVal, oldVal) {
                if (!newVal || !(typeof newVal == 'string' || newVal instanceof String) || newVal == oldVal) {
                  return;
                } else {
                  datesChanged(attrs.refreshOnDateRangeChange,scope);
                }
              })

              scope.$watch('data.startDate', function (newVal, oldVal) {
                if (!newVal || !(typeof newVal == 'string' || newVal instanceof String) || newVal == oldVal) {
                  return;
                } else {
                  datesChanged(attrs.refreshOnDateRangeChange, scope);
                }
              })

              scope.$watch('data.reason', function (newVal, oldVal) {
                if (!newVal || (oldVal && newVal.value == oldVal.value)) {
                  return;
                } else {
                  datesChanged(attrs.refreshOnDateRangeChange, scope);
                }
              })


            }
        }
    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('refreshOnDateSelect', ['$log', function ($log) {

        function dateSelect(scope, attrs) {

            if (attrs.dateParam) {

                var params = {dataId: scope.opId};
                params[attrs.dateParam] = scope.data[attrs.dateParam];
                params['itemId'] = scope.itemId;
                if (scope.errors && scope.errors.errors) {
                    scope.errors.errors = undefined;
                }
                if (scope.errors && scope.errors.warnings) {
                    scope.errors.warnings = undefined;
                }
                if (scope.errors && scope.errors.information) {
                    scope.errors.information = undefined;
                }
                scope.$parent.refreshOperationData(params);
            }
        }

        return {
            restrict: 'EA',
            link: function (scope, element, attrs) {
                scope.$watch(function () {
                    return scope.data[attrs.dateParam];
                }, function (newVal, oldVal) {
                    $log.debug('SelectedDate value is...... ' +JSON.stringify(newVal));
                    if (!newVal || !(typeof newVal == 'string' || newVal instanceof String) || newVal == oldVal) {
                        return;
                    } else {
                        dateSelect(scope, attrs);
                    }
                })
            }
        };


    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('refreshOnLibraryItemSelect', ['$log', function ($log) {

    function libraryItemSelect(scope, attrs) {
        /* refreshOnLibraryItemSelect is the operation id */

        if (attrs.refreshSelectedItem) {
            $log.debug('operation id........' + attrs.refreshOnLibraryItemSelect);
            var params = {dataId: attrs.refreshOnLibraryItemSelect};
            if (attrs.itemIdParamName == 'itemId'){
                params[attrs.itemIdParamName] = 'SkillLibraryItem' + scope.data[attrs.refreshSelectedItem].value;
            }
            else {
                params[attrs.itemIdParamName] = scope.data[attrs.refreshSelectedItem].value;
            }
            $log.debug('params are........' + JSON.stringify(params));
            scope.$parent.refreshOperationData(params);
            scope.itemSelected = true;      /* used in form validation */
        }
    }

        return {
            restrict: 'EA',
            link: function (scope, element, attrs) {
              scope.$watch(function () {
                  return scope.data[attrs.refreshSelectedItem];
              }, function (newVal, oldVal) {
                  $log.debug('refreshSelectedItem is...... ' +JSON.stringify(newVal));
                  if (attrs.refreshSelectedItem=='competency' && newVal == undefined && scope.data.indicators) {
                      scope.data.indicators = undefined; /*clear indicators if competency cleared */
                  }
                 else if (newVal && (!oldVal || oldVal.value != newVal.value)) {
                        libraryItemSelect(scope, attrs);
                }
              })
            }
        };


    }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('searchAssessorDirective', ['$log', 'ContactFactory', '$timeout', function ( $log, ContactFactory, $timeout) {
    return {
        scope: {
            searchField: '=searchField',
            requiredField: '=requiredField'
        },
        template: '<div>' +
            '<input type="text" class="form-control" placeholder="Search organisation" ng-model="searchString" ng-keyup="onKeyUp($event)" ng-required="requiredField" />'+
            '<select data-ng-attr-size="{{selectSize}}" ng-show="searchContactResults.length>0" class="form-control autocomplete" ng-model="searchField" ng-click="defaultValue()" ng-change="changedValue()" ng-options="option as option.name for option in searchContactResults track by option.id"></select>' +
            '</div>',
      restrict: 'EA',
        replace: true,
        link: function (scope, element, attrs) {

            var timer = false;

            scope.searchDone = false;
            scope.closeResults = false;

            scope.$watch("searchString", function (newValue, oldValue) {

                if (timer) {
                    $timeout.cancel(timer)
                }
                timer = $timeout(function () {

                if (newValue == "") {       // if search string changed to empty then make selected value and search string empty
                    scope.searchField.name = "";
                    scope.searchString = "";
                }
                else if (newValue) {
                    if (!scope.searchField || (scope.searchField && scope.searchField.name != newValue)) {

//check if more than 2 characters entered, if so call search function, passing input so far as search string
                        if (newValue.length >= 2) {
                                scope.searchContactResults = ContactFactory.query({
                                    search: scope.searchString,
                                    group: ''
                                });
                                scope.searchContactResults.$promise.then(function (result) {
                                    scope.searchContactResults = result;
                                    scope.searchDone = true;
                                    scope.searchField = scope.searchContactResults[0]; //set selected value to first value returned, so that empty value not shown in list
                                    if (scope.searchContactResults.length > 0) {
                                        scope.selectSize = scope.searchContactResults.length;
                                        $log.debug('select size is........ ' + scope.selectSize);
                                    }
                                }, function (error) {
                                    $log.error("Search failed: " + error.message);
                                    scope.searchContactResults = [];
                                    scope.searchDone = true;
                                });
                            }
                        }
                    }
                }, 500)
            });

            scope.changedValue = function () {
                if (scope.searchContactResults)
                {
                    $log.debug('option selected, not default first option');
                    scope.searchField.value = scope.searchField.id; //nasty hack due to search results having id attribute but competency assessments requiring value attribute
                    scope.searchString = scope.searchField.name;
                    $log.debug('selected value ........ ' +scope.searchField.name); //if a value selected, then revert back to an input field with that value displayed
                    scope.searchContactResults = []; //set results back to empty so that select no longer shown
                }
            };

            scope.defaultValue = function () {       /* this is used when the first (default) value is selected, even if there are many options) */
                $log.debug('default first option selected');
                scope.searchField.value = scope.searchField.id; //nasty hack due to search results having id attribute but competency assessments requiring value attribute
                scope.searchString = scope.searchField.name; //if a value selected, then revert back to an input field with that value displayed
                scope.searchContactResults = []; //set results back to empty so that select no longer shown
            };

        }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('searchDirective', ['AppConstants', function (AppConstants) {
    return {
      templateUrl: AppConstants.SEARCHCONTACTSVIEWSHTML,
      controller: 'SearchContactsCtrl',
      restrict: 'EA'
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('serviceBarMenu', ['$window', '$location', '$filter', 'AppConstants', '$log', '$timeout', 'Utils', function ($window, $location, $filter, AppConstants, $log, $timeout, Utils ) {
        return{
            scope: {
                navMenu: '=',
                navoperation: '&',
                navoperationsub: '&'
            },
            replace: true,
            template:
            '<ul id="category_tabs" class="nav nav-tabs marginSpacer myFlexMenu" ng-class="{\'hide-bar-overflow\':recalculating, \'allow-bar-overflow\':!recalculating}"> '+
            '<li ng-repeat="catItem in MainBar" class="dropdown" ng-class="{active:isActive(\'/services/{{catItem.id}}\',\'cat_tab_menu\')}" id="/services/{{catItem.id}}/processes">'+
            '<a href="" style="text-decoration: none; " data-toggle="dropdown">'+
            '<span ng-click="navoperation({catItemId: catItem.id})">{{catItem.label | translate | suppress}}</span>'+
            '<span class="caret" style="margin-left: 10px;"></span>'+
            '</a>'+
            '<ul class="dropdown-menu" >'+
            '<li ng-repeat="subNavItem in catItem.subLinks  | orderBy:\'order\'">'+
            '<a href="" ng-click="navoperationsub({catItemId: catItem.id, subNavItemId: subNavItem.id})">{{subNavItem.label | translate | suppress}}</a>'+
            '</li>'+
            '</ul>'+
            '</li>'+
            '<li ng-hide="showExtras" class="extra-bar"><div style="height:50px">&nbsp;</div></li>'+


            '<li class="flexMenu-viewMore extra-bar" ng-show="showExtras">'+
            '<a href="" class="moreLink" ng-click="toggleExtra()" ><span class="caret"></span></a>'+

            '<ul custom-accordion close-others="false" ng-show="openExtraStatus" class="nav-extra-accordion">'+

            '<ul custom-accordion-group ng-repeat="catItem in ExtraBar" is-open="isopen" >'+

            '<ul custom-accordion-heading>'+

            '<span class="vertical-alignment-helper"></span>'+
            '<img ng-src="'+ AppConstants.COLLAPSEACCORDIONWHITEIMGSRC +'" ng-show="isopen"/>'+
            '<img ng-src="' + AppConstants.EXPANDACCORDIONWHITEIMGSRC + '" ng-show="!isopen"/>'+
            '<a href="" ng-click="menuSwap(catItem.id, $index)" class="nav-extra-category">'+
            '{{catItem.label | translate | suppress}}'+
            '</a>'+

            '</ul>'+

            '<li ng-repeat="subNavItem in catItem.subLinks  | orderBy:\'order\'">'+
            '<a href="" ng-click="navoperationsubAccordion(catItem.id,subNavItem.id)">{{subNavItem.label | translate | suppress}}</a>'+
            '</li>'+



            '</ul>'+

            '</ul>'+

            '</li>'+



            '</ul>',
            link: function (scope, element, attrs) {
                var w = angular.element($window);
                scope.recalculating = false;
                scope.openExtraStatus = false;

                scope.navoperationsubAccordion = function(catItemId, subNavItemId){         // close extra menu then go to selected sub-menu item
                    scope.openExtraStatus = false;
                    scope.navoperationsub({catItemId: catItemId, subNavItemId: subNavItemId});
                };

                scope.toggleExtra = function () {
                    if(scope.openExtraStatus == false){
                        scope.openExtraStatus = true;
                    }else {
                        scope.openExtraStatus = false;
                    }
                };

                scope.isActive = function(route,mode) {
                    if (mode =='cat_tab_menu') {
                        return $location.path().indexOf(route) >= 0;
                    } else {
                        return false;
                    }
                };
                var serviceBar = [];
                scope.MainBar = [];
                scope.ExtraBar = [];
                scope.navCategoryItems = [];


                /* called when selecting an item from the ExtraBar or from location change*/
                scope.menuSwap = function(catgId, arrayId, locationChange){
                    scope.openExtraStatus = false;
                    var serviceBarSelectedServiceIndex = arrayId + scope.MainBar.length;
                    serviceBar.splice(serviceBarSelectedServiceIndex, 1);
                    serviceBar.unshift(scope.ExtraBar[arrayId]);
                    scope.MainBar = serviceBar;
                    scope.ExtraBar = [];
                    scope.recalculating = true;
                    $timeout(function(){
                        recalcServiceBar();
                    },0);
                    if (!locationChange) {
                        scope.navoperation({catItemId: catgId});
                    }
                };

                /* called when selecting from Nav Menu */
                /* loops through services in Extra Bar and if the one selected is in the Extra Bar, then calls menuSwap*/
                scope.$on('$locationChangeSuccess', function(newValue, oldValue, nextParams){
                    if(!newValue){
                        return;
                    } else {
                        var isThere = false;
                        var isThereId, isThereCount;
                        var arrayCount = 0;
                        angular.forEach(scope.ExtraBar, function (submenu) {
                            if($location.path().indexOf(submenu.id) >= 0){
                                isThereId = submenu.id;
                                isThere = true;
                                isThereCount = arrayCount;
                            }
                            arrayCount = arrayCount + 1;
                        });
                        if(isThere) scope.menuSwap(isThereId, isThereCount, true);
                    }
                });

                /* watch to trigger initial build of service bar */
                scope.$watch("navMenu",function(newValue,oldValue) {
                    $log.debug('navMenu watch fired!');
                    if(!newValue || !Array.isArray(newValue)){
                        return
                    }
                    if (oldValue && Array.isArray(oldValue) && serviceBar.length > 0) {
                        return;
                    }

                    serviceBar = [];
                    scope.navCategoryItems = $filter('orderBy')(newValue, 'order');

                    angular.forEach(scope.navCategoryItems, function (menu) {
                        var navCategorySubItems= [];
                        var processinstances = $filter('orderBy')(menu.processinstances, 'order');
                        angular.forEach(processinstances, function (submenu) {
                            navCategorySubItems.push({id:submenu.id, label: submenu.label});
                        });
                        serviceBar.push({id:menu.id, label: menu.label, subLinks: navCategorySubItems});
                    });

                    scope.showExtras = false;

                    $log.debug('nav category items is ' +scope.navCategoryItems);
                    $log.debug('nav category items length is ' +scope.navCategoryItems.length);

                    if(scope.navCategoryItems.length>0){
                        $log.debug('length > 0');
                        scope.recalculating = true;
                        $timeout(function(){
                            $log.debug('going to recalc service bar');
                            recalcServiceBar();
                        },0);
                    }
                    scope.MainBar = serviceBar;
                    scope.ExtraBar = [];

                    $log.debug('main bar is ' +scope.MainBar);
                    $log.debug('extra bar is ' +scope.ExtraBar);
                }, true);

                /* when window resized */
                w.bind('resize', function () {
                    scope.showExtras = false;
                    if(scope.navCategoryItems && scope.navCategoryItems.length>0){
                        scope.MainBar = serviceBar;
                        scope.recalculating = true;
                        $timeout(function(){
                            recalcServiceBar();
                        },0);
                    } else {
                        scope.MainBar = serviceBar;
                        scope.ExtraBar = [];
                    }
                    scope.$apply();
                });


                /* calculate how many services will fir in the MenuBar, put the others in the ExtraBar */
                function recalcServiceBar() {
                    $log.debug('Recalculating how many services fit on the bar');
                    scope.MainBar = [];
                    scope.ExtraBar = [];

                    scope.openExtraStatus= false;

                    var availableSpace = element.width();
                    availableSpace -= 70;
                    $log.debug('initial available space is ' +availableSpace);

                    Utils.findBySelector('#category_tabs li.dropdown').each(function (i, o) {
                        $log.debug('serviceBar element is ' +JSON.stringify(serviceBar[i]));
                        if (serviceBar[i]) {
                            if (scope.ExtraBar.length == 0 && availableSpace - o.offsetWidth > 0) {
                                scope.MainBar.push({
                                    id: serviceBar[i].id,
                                    label: serviceBar[i].label,
                                    subLinks: serviceBar[i].subLinks
                                });
                                $log.debug('current li element is ' + o.innerHTML);
                                $log.debug('offset width of current li element is ' +o.offsetWidth);
                                availableSpace = availableSpace - o.offsetWidth;
                                $log.debug('available space after adding a service is ' +availableSpace);
                            } else {
                                scope.showExtras = true;

                                $log.debug('Adding to Extra Bar');
                                scope.ExtraBar.push({id: serviceBar[i].id, label: serviceBar[i].label, subLinks: serviceBar[i].subLinks});
                            }
                        }
                    });
                    scope.recalculating = false;
                    return;
                }
            }
        }
    }])

    .factory('WindowWidthService', function() {
        return {
            'w': angular.element( document.querySelector( '.process-content' )).width()
        };
    });




/* EOF */
'use strict';

angular.module('fairsailWX')
	.directive('setValueOnScope', ['$log', function ($log) {
		return {
			scope: {
				setValueOnScope:'=',
				scopeValue: '='
			},
			restrict: 'A',
			link: function (scope, element, attrs) {
				scope.$watch('setValueOnScope', function (newVal) {
					if (newVal) {
						scope.scopeValue = attrs['setValue'];
					} else {
						scope.scopeValue = attrs['unsetValue'];
					}

					if (attrs['valueType'] == 'integer') {
						scope.scopeValue = parseInt(scope.scopeValue);
					}
				});
			}
		};
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX')
    .directive('singlemonth', ['$locale', 'pickadateUtils', 'dateFilter', '$timeout', function($locale, pickadateUtils, dateFilter, $timeout) {
        return {


            require: 'ngModel',
            scope: {
                date: '=ngModel',
                defaultDate: '=',
                minDate: '=',
                maxDate: '=',
                setMonths: '=',
                allAbsences:'=',
                allCoyholidays: '=',
                dayoffDates: '=',
                vacationDates: '=',
                holidayDates: '=',
                weekendDates: '=',
                coyholidayDates: '=',
                dial: "&",
                changeyear: "&"
            },
            replace: true,
            template:
                '<div class="pickadate">' +
                '<div class="pickadate-header">' +
                '<div class="pickadate-controls">' +
                '<a href="" class="pickadate-prev" ng-click="changeMonth(-1)" ng-show="allowPrevMonth">&larr; {{\'fHCM2__Button_Previous\'  | translate | suppress}}</span></a>' +
                '<a href="" class="pickadate-next" ng-click="changeMonth(1)" ng-show="allowNextMonth">{{\'fHCM2__Button_Next\'  | translate | suppress}} &rarr;</span></a>' +
                '</div>'+
                '<h3 class="pickadate-centered-heading">' +
                '{{currentDate | date:"MMMM yyyy"}}' +
                '</h3>' +
                '</div>' +
                '<div class="pickadate-body">' +
                '<div class="pickadate-main">' +
                '<ul class="pickadate-cell">' +
                '<li class="pickadate-head" ng-repeat="dayName in dayNames">' +
                '{{dayName}}' +
                '</li>' +
                '</ul>' +
                '<ul class="pickadate-cell">' +
                '<li ng-repeat="d in dates" ng-click="dial({selectedDate: d.date, selectedClass: d.className, selectedMode: \'mobile\'})" tooltip="{{d.tooltipMessage}}" class="{{d.className}}" ng-class="{\'pickadate-active\': date == d.date, \'pending\': d.myAbsenceStatus == \'Pending\', \'provisional\': d.myAbsenceStatus == \'Provisional\', \' \': d.myAbsenceStatus == \'Approved\'}">' +
                '{{d.date | date:"d"}}' +
                '</li>' +
                '</ul>' +
                '</div>' +
                '</div>' +
                '</div>',


            link: function(scope, element, attrs, ngModel) {
				var initialLoad = true;
                scope.$watch("minDate",function(newValue,oldValue) {
                    //This gets called when data changes.

                    if (newValue) {
                        $timeout(function () {
							var minDate = newValue && pickadateUtils.stringToDate(newValue);


							scope.dayNames = $locale.DATETIME_FORMATS['SHORTDAY'];

							scope.myMonths = [];

							var d = initialLoad && minDate.getFullYear() == new Date().getFullYear()  ? new Date() : new Date(minDate);
							initialLoad = false;

							if (d != 'Invalid Date') {
								if(scope.setLastMonthPrev) {
									d.setMonth(11);
									scope.render(d);
								}  else if(scope.setLastMonthNext) {
									d.setMonth(0);
									scope.render(d);
								} else {
									d.setMonth(d.getMonth());
									scope.render(d);
								}
							}
                        }, 0);
                    }
            });
                scope.render = function (initialDate) {
                    initialDate = new Date(initialDate.getFullYear(), initialDate.getMonth(), 1, 3);
                    var currentMonth = initialDate.getMonth() + 1,
                        dayCount = new Date(initialDate.getFullYear(), initialDate.getMonth() + 1, 0, 3).getDate(),
                        prevDates = pickadateUtils.dateRange(-initialDate.getDay(), 0, initialDate),
                        currentMonthDates = pickadateUtils.dateRange(0, dayCount, initialDate),
                        lastDate = pickadateUtils.stringToDate(currentMonthDates[currentMonthDates.length - 1]),
                        nextMonthDates = pickadateUtils.dateRange(1, 7 - lastDate.getDay(), lastDate),
                        allDates = prevDates.concat(currentMonthDates, nextMonthDates),
                        dates = [],
                        today = dateFilter(new Date(), 'yyyy-MM-dd');
                    scope.currentDate = pickadateUtils.stringToDate(dateFilter(initialDate, 'yyyy-MM-dd'));

                    // Add an extra row if needed to make the calendar to have 6 rows
                    if (allDates.length / 7 < 6) {
                        allDates = allDates.concat(pickadateUtils.dateRange(1, 8, allDates[allDates.length - 1]));
                    }

                    var nextMonthInitialDate = new Date(initialDate);
                    nextMonthInitialDate.setMonth(currentMonth);

                    // nextMonthInitialDate.setMonth(currentMonth);

                    var indexOf = [].indexOf || function (item) {
                        for (var i = 0, l = this.length; i < l; i++) {
                            if (i in this && this[i] === item) return i;
                        }
                        return -1;
                    };
                    scope.allowPrevMonth = true;
                    scope.allowNextMonth = true;

                    for (var i = 0; i < allDates.length; i++) {
                        var className = "", tooltipMessage = "", myTooltipMessage = "", myAbsenceStatus = "", date = allDates[i];
                        var wkd = new Date(date);

                        if (dateFilter(date, 'M') !== currentMonth.toString()) {
                            className = 'pickadate-disabled';
                            //className = 'pickadate-enabled';
                        } else if (indexOf.call(scope.dayoffDates, date) >= 0) {
                            className = 'pickadate-enabled pickadate-dayoff';
                            angular.forEach(scope.allAbsences, function (thisDate) {
                                if (thisDate.myDate === date) {
                                    myTooltipMessage = thisDate.myReason;
                                    myAbsenceStatus = thisDate.myStatus;
                                }
                            });
                            tooltipMessage = myTooltipMessage;

                        } else if (indexOf.call(scope.vacationDates, date) >= 0) {
                            className = 'pickadate-enabled pickadate-vacation';
                        } else if (indexOf.call(scope.holidayDates, date) >= 0) {
                            //console.log('dates holiday = '+date)
                            className = 'pickadate-enabled pickadate-holiday';
                            angular.forEach(scope.allAbsences, function (thisDate) {
                                if (thisDate.myDate === date) {
                                    myTooltipMessage = thisDate.myReason;
                                    myAbsenceStatus = thisDate.myStatus;
                                }
                            });
                            tooltipMessage = myTooltipMessage;
                        } else if (indexOf.call(scope.coyholidayDates, date) >= 0) {
                            //console.log('dates holiday = '+date)
                            className = 'pickadate-enabled pickadate-coyholiday';
                            angular.forEach(scope.allCoyholidays, function (thisDate) {
                                if (thisDate.myDate === date) {
                                    myTooltipMessage = thisDate.myLabel;
                                    myAbsenceStatus = thisDate.myStatus;
                                }
                            });
                            tooltipMessage = myTooltipMessage;
                        } else if (indexOf.call(scope.weekendDates, date) >= 0)
                            className = 'pickadate-disabled pickadate-weekend';
                        else {
                            className = 'pickadate-enabled';
                        }

                        if (date === today) {
                            className += ' pickadate-today';
                        }

                        dates.push({date: date, className: className, tooltipMessage: tooltipMessage, myAbsenceStatus: myAbsenceStatus});

                    }

                    //return dates

                    scope.dates = dates;
                };

                scope.changeMonth = function (offset) {
                    // alert('singlemonth')
                    // If the current date is January 31th, setting the month to date.getMonth() + 1
                    // sets the date to March the 3rd, since the date object adds 30 days to the current
                    // date. Settings the date to the 2nd day of the month is a workaround to prevent this
                    // behaviour

                    //scope.currentDate.setDate(1);
                    //scope.changeyear({offset: 2016});
                    var playDate = new Date(scope.currentDate);
                    var thisYr = playDate.getFullYear();
                    var nextYr = new Date(playDate.setMonth(playDate.getMonth() + offset)).getFullYear();

                    if(thisYr == nextYr) {
                        scope.currentDate.setMonth(scope.currentDate.getMonth() + offset);
                        scope.lastMonth = scope.currentDate.getMonth();
                        scope.setLastMonthPrev = false;
                        scope.setLastMonthNext = false;
                        scope.render(scope.currentDate);
                    } else {
                        if(thisYr > nextYr) {
                            scope.lastMonth = scope.currentDate.getMonth();
                            scope.setLastMonthPrev = true;
                            scope.setLastMonthNext = false;
                            scope.changeyear({offset: nextYr});

                        } else {
                            scope.lastMonth = scope.currentDate.getMonth();
                            scope.setLastMonthNext = true;
                            scope.setLastMonthPrev = false;
                            scope.changeyear({offset: nextYr});

                        }

                    }

                };



        }



        };
    }]);




/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('sliderBar', ['$log', 'Utils', function ($log, Utils) {
    return {
        scope: {
         //   questionScale: '=questionScale',
          questionNumber: '=questionNumber',
       //     sliderValue:'=value'
			options:'=sliderOptions',
			sliderModel:'='
        },
        template:
        '<input id="slider{{initialQuestionNumber}}" type="text" style="display: none;" ng-model="sliderValue" />',
      restrict: 'A',
        replace: true,
        link: function (scope, element, attrs) {
			function createSlider() {
			}

			scope.initialQuestionNumber = scope.questionNumber;

            scope.$watch("questionNumber", function (newValue, oldValue) {
                if(newValue) {
					if (scope.slider) {
						scope.slider.slider('destroy');
					}

					var ticks = [];
					var tick_labels = [];

					var initialValue = 0;
					angular.forEach(scope.options, function (option, key) {
						$log.debug('Option for slider = ' + option.value + ' : ' + option.name);
						ticks.push(key);
						tick_labels.push(option.name);

						if (scope.sliderModel && scope.sliderModel.name == option.name) {
							initialValue = key;
						}
					});

					scope.sliderValue = initialValue;
					scope.sliderModel = scope.options[scope.sliderValue];

					scope.slider = 	Utils.createSlider('#slider' + scope.initialQuestionNumber, ticks, tick_labels, initialValue, 30);

					scope.slider.slider('on', 'change', function(change) {
						scope.sliderValue = change.newValue;
						scope.$digest();
					})
				}
            });

			scope.$watch("sliderValue", function (newVal) {
				$log.debug('Slider ' + '#slider'+scope.initialQuestionNumber + ' value = ' + newVal);
				if (newVal != undefined) {
					scope.sliderModel = scope.options[newVal];
				} else {
					scope.sliderModel = undefined;
				}
				$log.debug('Slider ' + '#slider'+scope.initialQuestionNumber + ' option = ' + (scope.sliderModel ? scope.sliderModel.name : 'undefined'));
			})
        }
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('sortIntoRowsDirective', ['$log', 'Utils', function ( $log, Utils) {
    return {
        scope: {
            thingsToSort: '=thingsToSort',
            thingsInRows: '=thingsInRows',
            columnStyle: '=columnStyle'
        },

      restrict: 'A',

        link: function (scope, element) {

            scope.$watch("thingsToSort", function (newValue, oldValue) {
                if(newValue && newValue!=oldValue) {
                scope.thingsInRows = Utils.sortPeopleIntoColumns(scope.thingsToSort, scope.$parent.displayMode);
                scope.columnStyle = Utils.getNumberOfPeopleColumnsAvailable(scope.$parent.displayMode);
            }
            });

            scope.$watch("$parent.displayMode", function (newValue, oldValue) {

                if(newValue && scope.thingsToSort) {
                    scope.thingsInRows = Utils.sortPeopleIntoColumns(scope.thingsToSort, scope.$parent.displayMode);
                    scope.columnStyle = Utils.getNumberOfPeopleColumnsAvailable(scope.$parent.displayMode);
                }
            });

        }

    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('stepThroughList', ['$log', function ($log) {
		var currentIndex = 0;

		return {
		  transclude: true,
		  restrict: 'EA',
		  scope: {
			  collection:"=stepThroughList",
			  current:"="
		  },
		  template: "<div ng-transclude></div>",
		  link: function postLink(scope, element, attrs) {
			  if (!scope.collection || scope.collection.length < 1) {
				  $log.error('No collection');
				  return;
			  }


			  var items = [];
			  if (attrs.childList) {
				  var parentIndex = 0;

				  angular.forEach(scope.collection, function (item) {
					  item.index = parentIndex++;
                      angular.forEach(item[attrs.childList], function (subItem) {
						  subItem.index = items.length;
                          items.push(subItem);
                          if (subItem.score) {
                              angular.forEach(subItem.scale.options, function (option) {
                                  if(option.value == subItem.score.value){
                                      subItem.score = option;
                                  }

                              })

                          }
                      })
                  });
			  } else {
				  angular.forEach(scope.collection, function (item) {
					  item.index = items.length;
					  items.push(item);
				  });
			  }

			  if (attrs.childList && attrs.loopOverChildList == 'true') {
				  var childIndex = 0;
				  scope.current = scope.collection[currentIndex][attrs.childList][childIndex];

				  scope.$parent.prev = function () {
					  if (childIndex > 0) {
						  childIndex--;
					  } else {
						  if (currentIndex > 0) {
							  currentIndex--;
							  childIndex = scope.collection[currentIndex][attrs.childList].length -1;
						  }
					  }

					  scope.current = scope.collection[currentIndex][attrs.childList][childIndex];
				  }

				  scope.$parent.hasPrev = function () {
					  if (childIndex > 0) {
						  return true;
					  } else {
						  if (currentIndex > 0) {
							  return true;
						  }
					  }

					  return false;
				  }

				  scope.$parent.next = function () {
					  if (childIndex < (scope.collection[currentIndex][attrs.childList].length - 1)) {
						  childIndex++;
					  } else {
						  if (currentIndex < (scope.collection.length - 1)) {
							  currentIndex++;
							  childIndex = 0;
						  }
					  }

					  scope.current = scope.collection[currentIndex][attrs.childList][childIndex];
				  }

				  scope.$parent.hasNext = function () {
					  if (scope.$parent.isCurrentComplete()) {
						  if (childIndex < (scope.collection[currentIndex][attrs.childList].length - 1)) {
							  return true;
						  } else {
							  if (currentIndex < (scope.collection.length - 1)) {
								  return true;
							  }
						  }
					  }

					  return false;
				  }
			  } else {
				  scope.current = scope.collection[currentIndex];

				  scope.$parent.prev = function () {
					  if (currentIndex > 0) {
						  currentIndex--;
						  scope.current = scope.collection[currentIndex];
					  }
				  }

				  scope.$parent.hasPrev = function () {
					  return currentIndex > 0;
				  }

				  scope.$parent.next = function () {
					  if (currentIndex < (scope.collection.length - 1)) {
						  currentIndex++;
						  scope.current = scope.collection[currentIndex];
					  }
				  }

				  scope.$parent.hasNext = function () {
					  if (scope.$parent.isCurrentComplete()) {
						  if (currentIndex < (scope.collection.length - 1)) {
							  return true;
						  }
					  }

					  return false;

				  }
			  }

			  scope.$parent.count = function () {
				  if (attrs.childList && attrs.loopOverChildList == 'true') {
					  return items.length;
				  } else {
					  return scope.collection ? scope.collection.length : 0;
				  }
			  }

			  scope.$parent.index = function () {
				  if (attrs.childList && attrs.loopOverChildList == 'true') {
					  return scope.current ? scope.current.index : 0;
				  } else {
					  return currentIndex;
				  }
			  }

			  function itemComplete(item, overrideIgnore) {
				  if (overrideIgnore || (attrs.isNotRequiredField && !item[attrs.isNotRequiredField])) {
					  if (item[attrs.completeField]
						  && item[attrs.completeField].name
						  && item[attrs.completeField].name.length > 0
						  && (item[attrs.completeField].length > 1 || item[attrs.completeField].name.indexOf(' ') != 0)) {
						  return true;
					  }
				  } else {
					  return true;
				  }

				  return false;
			  }

			  scope.$parent.isCurrentComplete = function(overrideIgnore) {
				  if (scope.current) {
					  if (attrs.childList && attrs.loopOverChildList != 'true') {
						  var complete = true;
						  var completeCount = 0;

						  // all the mandatory questions should be answered
						  angular.forEach(scope.current[attrs.childList], function (item) {
							  if (complete) {
								  complete = itemComplete(item);
							  }

							  if (itemComplete(item, overrideIgnore)) {
								  completeCount++;
							  }
						  });

						  // at last one question should be answered
						  return complete && completeCount > 0;
					  } else {
						  return itemComplete(scope.current, overrideIgnore);
					  }
				  } else {
					  return false;
				  }

			  }

			  scope.$parent.isComplete = function() {
				  var complete = 0;

				  if (attrs.completeField) {
					  angular.forEach(items, function (item) {
						  if (itemComplete(item)) {
							  complete++;
						  }
					  });
					  $log.debug('items complete = ' + complete + ' out of ' + items.length)
					  return complete == items.length;
				  } else {
					  return true;
				  }
			  }

			  /*
			   // move to first incomplete item after last complete item
			   if (attrs['jumpToNext']) {
			   var startIndex = -1;
			   while (true) {
			   if (!scope.$parent.isCurrentComplete(true)) {
			   $log.debug('no result for ' + scope.current.index);
			   if (startIndex < 0) {
			   startIndex = scope.current.index;
			   }
			   } else {
			   startIndex = -1;
			   }

			   if (scope.$parent.hasNext()) {
			   scope.$parent.next();
			   } else {
			   break;
			   }
			   }

			   // rewind
			   $log.debug('rewinding to beginning');
			   while (scope.$parent.hasPrev()) {
			   scope.$parent.prev();
			   $log.debug('rewound to ' + scope.current.index);
			   }

			   if (startIndex >= 0) {
			   $log.debug('moving forward to ' + startIndex);

			   while (scope.current.index != startIndex) {
			   scope.$parent.next();
			   }
			   }
			   }

			   */

			  // move to first incomplete item after last complete item
			  if (attrs['jumpToNext']) {
				  $log.debug('finding start index');
				  var startIndex = -1;

				  // rewind sometimes the directive is not reconstructed completely
				  $log.debug('rewinding to beginning');
				  while (scope.$parent.hasPrev()) {
					  scope.$parent.prev();
					  $log.debug('rewound to ' + scope.current.index);
				  }

				  while (true) {
					  if (scope.$parent.isCurrentComplete()) {
						  if (scope.$parent.isCurrentComplete(true)) {
							  $log.debug('complete result for ' + scope.current.index);
							  startIndex = scope.current.index + 1;
						  } else {
							  $log.debug('incomplete result for ' + scope.current.index);
							  if (startIndex < 0) {
								  startIndex = scope.current.index;
							  }
						  }
					  } else {
						  $log.debug('no result for ' + scope.current.index);
					  }

					  if (scope.$parent.hasNext()) {
						  $log.debug('next');
						  scope.$parent.next();
					  } else {
						  break;
					  }
				  }

				  // rewind
				  $log.debug('rewinding to beginning');
				  while (scope.$parent.hasPrev()) {
					  scope.$parent.prev();
					  $log.debug('rewound to ' + scope.current.index);
				  }

				  $log.debug('movng forwards to start index ' + startIndex);

				  if (startIndex >= 0) {
					  $log.debug('moving forward to ' + startIndex);

					  while (scope.$parent.hasNext() && scope.current.index < startIndex) {
						  scope.$parent.next();
					  }
				  }
			  }
		  }
		};
  }]);


/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('teamHierarchyDirective', ['AppConstants', function (AppConstants) {
    return {
        templateUrl:AppConstants.TEAMHIERARCHYVIEWSHTML,
        controller: 'TeamHierarchyCtrl',
        restrict: 'EA'
    };
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX')
  .directive('tileFieldSet', ['AppConstants', 'Utils', function (AppConstants, Utils) {
    return {
        templateUrl:AppConstants.TILEFIELDSETVIEWSHTML,
        //template:'<div></div>',
      restrict: 'EA',
      scope: {
          tileFieldSet:'=tileFieldSet'
        },
      link: function (scope, element, attrs) {

          if (attrs.emptyLabel) {
              scope.emptyLabel = attrs.emptyLabel;
          } else {
              scope.emptyLabel = "N/A"
          }

		  if (attrs['rounding'] && parseInt(attrs['rounding']) != NaN) {
			  scope.roundToDecimalPlaces = parseInt(attrs['rounding']);
		  }

          scope.$watch('tileFieldSet', function (newVal, oldVal) {
              if (newVal) {
                  scope.orderedFieldSet = Utils.orderFieldSet(newVal);
                  scope.populatedFieldSet = [];
                  angular.forEach(scope.orderedFieldSet, function(value, index)
                      {
                          if (scope.orderedFieldSet[index].value) {
                              scope.populatedFieldSet.push(scope.orderedFieldSet[index]);
                      }
                          if (scope.orderedFieldSet[index].option && scope.orderedFieldSet[index].option.value) {
                              scope.populatedFieldSet.push(scope.orderedFieldSet[index]);
                          }
                  });
              }
          });
          scope.tileFieldLimitTo = attrs.tileFieldLimit;
       }
    };
  }]);

/* EOF */
'use strict';
var editorIds = 0;

angular.module('fairsailWX')
  .directive('tinyMce', ['$log', 'AppConstants', '$window', function ($log, AppConstants, $window) {
        return {

            scope: {
                tinymceAttribute: '='
            },
            template: '<textarea name="richtextarea" rows="10" ng-required="tinymceAttribute.required" ui-tinymce="tinymceOptions" class="tinymce{{tinymceid}} form-control" ng-class="{\'input-error\':tinymceAttribute.required}" ng-model="tinymceAttribute.value"></textarea>',
            restrict: 'A',
            replace: true,
            compile: function compile(tElement, tAttrs, transclude) {
                return {
                    pre: function preLink(scope, iElement, iAttrs, controller) {
                        scope.tinymceOptions = {
                            selector: "textarea.tinymce" + editorIds,
                            plugins: ["link image"],
                            menubar: false,
                            statusbar: false,
                            toolbar: "undo redo | bold italic underline strikethrough | link image | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent",
                            content_css: AppConstants.CUSTOMTINYMCERESOURCE
                        };
                        scope.tinymceid = editorIds;
                        editorIds++;
                    },
                    post: function postLink(scope, element, attrs, controller) {

                        $(document).on('focusin', function (event) {
                            if ($(event.target).closest(".mce-window").length) {
                                event.stopImmediatePropagation();
                            }
                        });

                        scope.$watch("tinymceAttribute.value", function (newVal) {

                            if ($window.tinyMCE.editors['ui-tinymce-' + scope.tinymceid] && newVal) {
                                var editor = $window.tinyMCE.editors['ui-tinymce-' + scope.tinymceid];
                                if (editor.getContent({format : 'raw'}) != newVal){
                                    $log.debug('Active editor content is....' + editor.getContent({format : 'raw'}));
                                    $log.debug('New value = ' + newVal);
                                    editor.setContent(newVal);
                                }
                            }

                        })
                    }
                }
            }
        }

  }]);

/* EOF */
angular.module('fairsailWXFilters')
    .filter('array', function() {
        return function(arrayLength) {
            arrayLength = Math.ceil(arrayLength);
            var arr = new Array(arrayLength), i = 0;
            for (; i < arrayLength; i++) {
                arr[i] = i;
            }
            return arr;
        };
    });
/* EOF */
angular.module('fairsailWXFilters')
    .filter('suppress', function() {
        return function(input) {
            if (input && (input.indexOf('__') > 0 || input.indexOf('WX_') == 0)) {
                return ' ';
            } else {
                //alert('input translated ' + input);
                return input;
            }
        }
    }
);
/* EOF */
angular.module('fairsailWXFilters')
    .filter('truncate', function() {
        return function(input, maxlength) {
            input = input || '';
            var out = "";

             maxlength = maxlength || 40;

             if (input.length) {
                 if (input.length > maxlength) {
                    out = input.substring(0, maxlength - 4) + ' ...';
                 } else {
                    out = input;
                 }
             }
             return out;
        }
    }
);
/* EOF */
/**
 * Created by CarolineR on 22/09/2015.
 */
angular.module('fairsailWXFilters')
    .filter('trustAsHtml',['$sce', function($sce) {
        return function(val) {
            return $sce.trustAsHtml(val);
        };
    }])
/* EOF */
angular.module('fairsailWXFilters')
  .filter('trustAsResourceUrl',['$sce', function($sce) {
    return function(val) {
      return $sce.trustAsResourceUrl(val);
    };
  }])

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ActionsFactory', ['$q', 'LoadingNotifyService', '$timeout', function ($q, LoadingNotifyService, $timeout) {

    var actions;
    var wasSet = false;
    var promises = [];

        return {
            query: function(params) {
              if (params.teamMemberId) {
                var options = {date: new Date().toString()};
                var deferred = $q.defer();

                fHCM2.CollaborationPortalRAController.getProcessActionsForTeamMember(params.teamMemberId, options, function (result, event) {
                  var parsedResult = JSON.parse(result);
                  if(event.status) {
                    deferred.resolve(parsedResult);
                  } else {
                    deferred.reject('Fetch actions failed');
                  }

                  LoadingNotifyService.finishedLoading('ActionsFactory');
                }, {escape: false});

                LoadingNotifyService.startLoading('ActionsFactory');

                return {$promise: deferred.promise};
              } else {

                if (actions) {
                  var deferred = $q.defer();

                  $timeout(function () {
                    deferred.resolve(actions)
                  }, 0);

                  return {$promise: deferred.promise};
                } else {
                  if (promises.length == 0) {
                    var options = {date: new Date().toString()};

                    fHCM2.CollaborationPortalRAController.getProcessActions(options, function (result, event) {
                      var parsedResult = JSON.parse(result);
                      if (event.status) {
                        actions = parsedResult;
                        wasSet = true;

                        angular.forEach(promises, function (promise) {
                          promise.resolve(actions);
                        });

                        promises.length = 0;
                      } else {
                        angular.forEach(promises, function (promise) {
                          promise.reject('Failed to fetch actions');
                        });

                        promises.length = 0;
                      }
                      LoadingNotifyService.finishedLoading('ActionsFactory');
                    }, {escape: false});

                    LoadingNotifyService.startLoading('ActionsFactory');
                  }

                  var deferred = $q.defer();

                  promises.push(deferred);

                  return {$promise: deferred.promise};
                }
              }
            },
            clear: function() {
                actions = undefined;
            },
            isClear: function() {
                return wasSet && !actions;
            }

        }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ActionsHelper', ['$log', 'ActionsFactory', 'UserFactory', 'CategoryFactory', '$q', '$filter', 'ProcessDataFactory',
	function ($log, ActionsFactory, UserFactory, CategoryFactory, $q, $filter, ProcessDataFactory) {
		var helper = {
			getActions: function (teamMemberId) {
				var deferred = $q.defer();

				refreshActions(deferred, teamMemberId);

				return {$promise: deferred.promise};
			},
			clear: function () {
				ActionsFactory.clear();
			},
			isClear: function () {
				return ActionsFactory.isClear();
			},
			doOperation: function (operationId, data, itemId, childId, refresh, teamMemberId, processId) {
				if (!processId) {
					$log.error('ActionsHelper:doOperation no processId');
					return;
				}

				var deferred = $q.defer();
				var operation = new ProcessDataFactory();
				operation.params = data;
				operation.$save({
					"teamMemberId": teamMemberId,
					"processId": processId,
					"dataType": "operations",
					"dataId": operationId,
					"itemId": itemId
				}).then(function (result) {
					deferred.resolve(result);
				}, function (error) {
					$log.error('operation failed ' + error);
					deferred.reject(error);
				});
				return {$promise: deferred.promise};
			},
			transformedActionsAsList: function (transformedActions) {
				var actions = [];

				if (transformedActions) {
					angular.forEach(transformedActions, function (service) {
						angular.forEach(service.processes, function (process) {
							angular.forEach(process.actions, function (action) {
								var newAction = jQuery.extend(true, {}, action);
								actions.push(newAction);
							})
						})
					})
				}

				return actions;
			}
		}

		function refreshActions(deferred, teamMemberId) {
			var transformedActions;

			var params = {};
			if (teamMemberId != UserFactory.teamMemberId) {
				params.teamMemberId = teamMemberId;
			}

			var def = ActionsFactory.query(params);
			def.$promise.then(function (actions) {
				var count = 0;
				var navigationItems = CategoryFactory.query({teamMemberId: teamMemberId});
				navigationItems.$promise.then(function (categories) {

					transformedActions = buildStructure(categories, transformedActions);

					count++;
					if (count == 2) {
						processActions(actions, transformedActions, deferred);
					}
				});


				var teamReportsNavigationItems = CategoryFactory.query({
					teamMemberId: teamMemberId,
					team: 'All Reports'
				});
				teamReportsNavigationItems.$promise.then(function (categories) {

					transformedActions = buildStructure(categories, transformedActions);

					count++;
					if (count == 2) {
						processActions(actions, transformedActions, deferred);
					}
				});

				angular.forEach(actions, function (action) {
					if (action.readOnly != true) {
						if (angular.equals(action.teamMemberId, teamMemberId) && (teamMemberId != UserFactory.teamMemberId)) {
							action.readOnly = true;
						} else {
							action.readOnly = false;
						}
					}
				});
			});
		}

		function processActions(actions, transformedActions, deferred) {
			if (!actions || actions.length == 0) {
				deferred.resolve({allActions: [], transformedActions: [], otherActions: []});

				return;
			}

			$log.debug('processActions ' + actions.length);

			transformedActions = orderStructure(transformedActions);

			transformedActions = associateActionsWithProcesses(actions, transformedActions);
			removeEmpty(transformedActions);

			var otherActions = [];
			angular.forEach(actions, function (action) {

				if (!action.used) {
					if (!action.processId && !action.processProxyId) {
						action.readOnly = true;
					}
					otherActions.push(action);
				}
			});

			if (otherActions.length == 0) {
				otherActions = undefined;
			}

			$log.debug('processed actions');

			deferred.resolve({allActions: actions, transformedActions: transformedActions, otherActions: otherActions});
		}

		function removeEmpty(sortedActions) {

			// iterate over the actions then find corresponding process and increment actions count
			angular.forEach(sortedActions, function (category) {
				category.show = false;
				angular.forEach(category.processes, function (instance) {
					if (instance.actions && instance.actions.length > 0) {
						category.show = true;
						instance.show = true;
					} else {
						instance.show = false;
					}
				});
			});
		}

		function associateActionsWithProcesses(actions, sortedActions) {
			if (!sortedActions) {
				sortedActions = [];
			}

			// iterate over the actions then find corresponding process and increment actions count
			actions.forEach(function (action) {
				angular.forEach(sortedActions, function (category) {
					angular.forEach(category.processes, function (instance) {
						// $log.debug('xxxxxxx process instance.length '+ instance.length);

						if (instance.processType == action.processType && (!action.processId || action.processId == instance.id)) {
							instance.actions.push(cloneAction(category, instance, action));
						}
					});
				});
			});

			return sortedActions;
		}

		function buildStructure(categories, sortedActions) {
			if (!categories || !jQuery.isArray(categories)) {
				return sortedActions;
			}
			if (!sortedActions) {
				sortedActions = [];
			}

			// iterate over the actions then find corresponding process and increment actions count
			categories.forEach(function (category) {
				category.processinstances.forEach(function (instance) {
					// $log.debug('xxxxxxx process instance.length '+ instance.length);
					function getContained(arr, id) {
						var match;
						angular.forEach(arr, function (elem) {
							//$log.debug('comparing ' + elem.id + ' with ' + id);
							if (elem.id == id) {
								//$log.debug('matched ' + elem.id);
								match = elem;
							}
						});

						return match;
					}

					var cat = getContained(sortedActions, category.id);
					//$log.debug("category.id  " + category.id);
					if (cat) {
						//$log.debug('matched service ' + category.id);
						var proc = getContained(cat.processes, instance.id);

						if (!proc) {
							var processActions = {};
							processActions.name = instance.label;
							processActions.id = instance.id;
							processActions.order = instance.order;
                            processActions.processType = instance.processType;
							processActions.actions = [];
							cat.processes.push(processActions);
						}
					} else {
						//$log.debug('adding service ' + category.id);
						var serviceActions = {};
						serviceActions.processes = [];
						serviceActions.id = category.id;
						serviceActions.name = category.label;
						serviceActions.order = category.order;

						//sortedActions.push(serviceActions.name);
						sortedActions.push(serviceActions);

						var processActions = {};
						processActions.name = instance.label;
						processActions.id = instance.id;
						processActions.order = instance.order;
						processActions.processType = instance.processType;
						processActions.actions = [];
						serviceActions.processes.push(processActions);
					}

				});
			});

			return sortedActions;
		}

		function orderStructure(sortedActions) {

			//$log.debug('Before sort ' + JSON.stringify(sortedActions));
			sortedActions = $filter('orderBy')(sortedActions, 'order');

			// iterate over the actions then find corresponding process and increment actions count
			angular.forEach(sortedActions, function (category) {
				$filter('orderBy')(category.processes, 'order');
			});

			//$log.debug('After sort ' + JSON.stringify(sortedActions));

			return sortedActions;
		}


		function cloneAction(category, instance, action) {
			action.used = true;
			var newAction = jQuery.extend(true, {}, action);

			newAction.serviceName = category.name;
			newAction.serviceId = category.id;
			newAction.processName = action.processName ? action.processName : instance.name;
			newAction.processId = instance.id;
			newAction.ticked = false;

			return newAction;
		}

		return helper;
	}
]);
/* EOF */
'use strict';

/*
 angular.module('fairsailWX')
 .constant('FSLOGO70x70IMGSRC', 'images/fstile70x70.png');
 */

angular.module('fairsailWX')
	//
	// Prefix FORCE URL PATH to the following CONSTANTS as required.
	//
	.constant('AppConstants', {
		'FORCEPATH':'', /* NOT REQUIRED*/
		'SCRIPTSDIR':'scripts',
		'BOWERDIR':'bower_components',
		'CUSTOMDIR':'custom',
		'IMAGEDIR':'images',
		'STYLESDIR':'styles',
		'CUSTOMTINYMCERESOURCE':'REPLACESTATICRESOURCE/custom/css/tinymce_override.css',
		'FSLOGO70x70IMGSRC':'REPLACESTATICRESOURCE/images/fstile70x70.png',
		'FSLOGO32x32IMGSRC':'REPLACESTATICRESOURCE/images/fstile32x32.png',
		'FAIRSAILLOGOIMGSRC':'REPLACESTATICRESOURCE/images/fairsail.png',
		'IMAGERECTIMGSRC':'REPLACESTATICRESOURCE/images/rectimage.png',
		'CLIENTLOGOIMGSRC':'REPLACESTATICRESOURCE/images/client_logo.jpg',
		'CLIENTTABICON':'images/client_tab_icon.png',
		'COLLAPSEACCORDIONWHITEIMGSRC':'REPLACESTATICRESOURCE/images/MINUS-10x2.png',
		'EXPANDACCORDIONWHITEIMGSRC':'REPLACESTATICRESOURCE/images/PLUS-10x10.png',
		'COLLAPSECONTACTGREYIMGSRC':'REPLACESTATICRESOURCE/images/collapse-line-grey-8x2.png',
		'EXPANDCONTACTGREYIMGSRC':'REPLACESTATICRESOURCE/images/expand-cross-grey-10x10.png',
		'CLOSEMENUWHITEIMGSRC':'REPLACESTATICRESOURCE/images/close-cross-10x10.png',
		'TEAMIMGSRC':'REPLACESTATICRESOURCE/images/team.png',
		'CALENDARLOADERIMGSRC':'REPLACESTATICRESOURCE/images/spiffygif_30x30.gif',
		'ORGCHARTIMGSRC':'REPLACESTATICRESOURCE/images/servers.png',

    //Social Media
    'FACEBOOKIMGSRC':'REPLACESTATICRESOURCE/images/facebook.png',
    'LINKEDINIMGSRC':'REPLACESTATICRESOURCE/images/linkedin.png',
    'TWITTERIMGSRC':'REPLACESTATICRESOURCE/images/twitter.png',
    'EMAILIMGSRC':'REPLACESTATICRESOURCE/images/email.png',

		// app level templateUrl paths referred in .when of app.js
		'SHOWCATEGORYVIEWSHTML':'REPLACESTATICRESOURCE/views/showcategory.html',
		'PERSONALDETAILSVIEWSHTML':'REPLACESTATICRESOURCE/views/personaldetails.html',
		'SHOWPROCESSVIEWSHTML':'REPLACESTATICRESOURCE/views/showprocess.html',
		'MODALVIEWSHTML':'REPLACESTATICRESOURCE/views/modal.html',
		'MODALITEMVIEWSHTML':'REPLACESTATICRESOURCE/views/viewitemmodal.html',
		'MODALIFRAMEVIEWSHTML':'REPLACESTATICRESOURCE/views/iframeModal.html',

		'DEFAULTTEAMMEMBERVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/defaultteammemberview.html',

		// Initialized scope variable with CONTACTVIEWSHTML path in searchcontactscontroller.js and teamhierarchycontroller.js and referred in respective .html files
		'CONTACTVIEWSHTML':'REPLACESTATICRESOURCE/views/contact.html',

		// scope variables for directives
		'MOBILESERVICEBARVIEWSHTML':'REPLACESTATICRESOURCE/views/mobileservicebar.html',
		'TEAMHIERARCHYVIEWSHTML':'REPLACESTATICRESOURCE/views/teamhierarchy.html',
		'NAVIGATIONVIEWSHTML':'REPLACESTATICRESOURCE/views/navigation.html',
		'SEARCHCONTACTSVIEWSHTML':'REPLACESTATICRESOURCE/views/searchcontacts.html',
		'ERRORSVIEWSHTML':'REPLACESTATICRESOURCE/views/errors.html',
		'DATEPICKERVIEWSHTML':'REPLACESTATICRESOURCE/views/datepicker.html',
		'CONFIRMDIALOGVIEWSHTML':'REPLACESTATICRESOURCE/views/dialogs/confirm.html',
    'CONFIRMWARNINGVIEWSHTML':'REPLACESTATICRESOURCE/views/dialogs/confirmwarning.html',
		//
		'MAINVIEWSHTML':'REPLACESTATICRESOURCE/views/main.html',
		'ORGCHARTVIEWSHTML':'REPLACESTATICRESOURCE/views/orgchart.html',
		'ACTIONSVIEWSHTML':'REPLACESTATICRESOURCE/views/actions.html',
		'SEARCHVIEWSHTML':'REPLACESTATICRESOURCE/views/advancedsearch.html',
		'FOOTERVIEWSHTML':'REPLACESTATICRESOURCE/views/footer.html',
		'ASSESSMENTVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/assessment.html',
    'TARGETSHEADERVIEWSHTML':'REPLACESTATICRESOURCE/views/processes/targets/templates/targetsaccordionheader.html',
    'TARGETSBODYVIEWSHTML':'REPLACESTATICRESOURCE/views/processes/targets/templates/targetsaccordionbody.html',
		'CONTACTDETAILSFIELDSETVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/contactdetailsfieldset.html',
		'FIELDSETVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/fieldset.html',
    'FIELDSETTABLEVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/fieldsettable.html',
    'FIELDSETTABLEMOBILEVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/fieldsettablemobile.html',
		'EDITFIELDSETVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/editfieldset.html',
		'TILEFIELDSETVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/tilefieldset.html',
		'PRINTABLEORGCHARTFIELDSETVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/printableorgchartfieldset.html',
        'ORGCHARTSTRUCTUREVIEWSHTML':'REPLACESTATICRESOURCE/views/templates/orgchartstructure.html',
    'SETTINGSVIEWSHTML' : 'views/settings.html',
		'MAXCONTACTSEARCHRESULTS': 50
    }

);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('CategoryFactory', ['$q', 'LoadingNotifyService', '$window', '$timeout', '$log', function ($q, LoadingNotifyService, $window, $timeout, $log) {
  var categoriesCache = {};
  var categoriesWasSet = false;

  if ($window.userViewport && $window.userCategories) {
    $log.debug('initialised with userCategories for ' + $window.userViewport.viewerId);
    categoriesCache[$window.userViewport.viewerId] = {};
    categoriesCache[$window.userViewport.viewerId].categories = $window.userCategories;
    categoriesCache[$window.userViewport.viewerId].promises = [];
    categoriesWasSet = true;
  }

  if ($window.userViewport && $window.userTeamCategories) {
    var team = 'All Reports';
    $log.debug('initialised with userTeamCategories for ' + $window.userViewport.viewerId);
    categoriesCache[$window.userViewport.viewerId+team] = {};
    categoriesCache[$window.userViewport.viewerId+team].categories = $window.userTeamCategories;
    categoriesCache[$window.userViewport.viewerId+team].promises = [];
    categoriesWasSet = true;
  }

  return {
        get: function(params) {
            var deferred = $q.defer();

            if (!params.team) {
                fHCM2.CollaborationPortalRAController.getCategory(params.teamMemberId, params.categoryId, function(result, event){
                    //alert('status = ' + status);
                    if(event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch category failed');
                    }
                  LoadingNotifyService.finishedLoading('CategoryFactory');
                }, {escape: false});
            } else {
                fHCM2.CollaborationPortalRAController.getTeamCategory(params.teamMemberId, params.team, params.categoryId, function(result, event){
                    //alert('status = ' + status);
                    if(event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch category failed');
                    }
                  LoadingNotifyService.finishedLoading('CategoryFactory');
                }, {escape: false});
            }

            LoadingNotifyService.startLoading('CategoryFactory');

            return {$promise: deferred.promise};
        },
        query: function(params) {
          if (!params.team) {
            if (categoriesCache && categoriesCache[params.teamMemberId] && categoriesCache[params.teamMemberId].categories) {
              var deferred = $q.defer();

              $timeout(function() {deferred.resolve(categoriesCache[params.teamMemberId].categories)}, 0);

              return {$promise: deferred.promise};
            } else {
              if (!categoriesCache) {
                categoriesCache = {};
              }
              if (!categoriesCache[params.teamMemberId]) {
                categoriesCache[params.teamMemberId] = {};
                categoriesCache[params.teamMemberId].promises = [];
              }
              if (categoriesCache[params.teamMemberId].promises.length == 0) {
                var qry = $q.defer();

                fHCM2.CollaborationPortalRAController.getCategories(params.teamMemberId, function(result, event){
                  //alert('status = ' + status);
                  if(event.status) {
                    qry.resolve(result);
                  } else {
                    qry.reject('Fetch categories failed');
                  }
                  LoadingNotifyService.finishedLoading('CategoryFactory');
                }, {escape: false});

                LoadingNotifyService.startLoading('CategoryFactory');


                  qry.promise.then(function (res) {
                  categoriesCache[params.teamMemberId].categories = res;
                  categoriesWasSet = true;

                  angular.forEach(categoriesCache[params.teamMemberId].promises, function (promise) {
                    promise.resolve(categoriesCache[params.teamMemberId].categories);
                  });

                  categoriesCache[params.teamMemberId].promises.length = 0;
                }, function () {
                  angular.forEach(categoriesCache[params.teamMemberId].promises, function (promise) {
                    promise.reject('Failed to fetch actions');
                  });

                  categoriesCache[params.teamMemberId].promises.length = 0;
                });
              }

              var deferred = $q.defer();

              categoriesCache[params.teamMemberId].promises.push(deferred);

              return {$promise: deferred.promise};
            }
          } else {
            if (categoriesCache && categoriesCache[params.teamMemberId+params.team] && categoriesCache[params.teamMemberId+params.team].categories) {
              var deferred = $q.defer();

              $timeout(function() {deferred.resolve(categoriesCache[params.teamMemberId+params.team].categories)}, 0);

              return {$promise: deferred.promise};
            } else {
              if (!categoriesCache) {
                categoriesCache = {};
              }
              if (!categoriesCache[params.teamMemberId+params.team]) {
                categoriesCache[params.teamMemberId+params.team] = {};
                categoriesCache[params.teamMemberId+params.team].promises = [];
              }
              if (categoriesCache[params.teamMemberId+params.team].promises.length == 0) {
                var qry = $q.defer();

                fHCM2.CollaborationPortalRAController.getTeamCategories(params.teamMemberId, params.team, function(result, event){
                  //alert('status = ' + status);
                  if(event.status) {
                    qry.resolve(result);
                  } else {
                    qry.reject('Fetch categories failed');
                  }
                  LoadingNotifyService.finishedLoading('CategoryFactory');
                }, {escape: false});

                  LoadingNotifyService.startLoading('CategoryFactory');

                  qry.promise.then(function (res) {
                  categoriesCache[params.teamMemberId+params.team].categories = res;
                  categoriesWasSet = true;

                  angular.forEach(categoriesCache[params.teamMemberId+params.team].promises, function (promise) {
                    promise.resolve(categoriesCache[params.teamMemberId+params.team].categories);
                  });

                  categoriesCache[params.teamMemberId+params.team].promises.length = 0;
                }, function () {
                  angular.forEach(categoriesCache[params.teamMemberId+params.team].promises, function (promise) {
                    promise.reject('Failed to fetch actions');
                  });

                  categoriesCache[params.teamMemberId+params.team].promises.length = 0;
                });
              }

              var deferred = $q.defer();

              categoriesCache[params.teamMemberId+params.team].promises.push(deferred);

              return {$promise: deferred.promise};
            }
          }

          /*
					  var deferred = $q.defer();

					  if (!params.team) {
						  fHCM2.CollaborationPortalRAController.getCategories(params.teamMemberId, function(result, event){
							  //alert('status = ' + status);
							  if(event.status) {
								  deferred.resolve(result);
							  } else {
								  deferred.reject('Fetch categories failed');
							  }
							  LoadingNotifyService.finishedLoading();
						  }, {escape: false});
					  } else {
						  fHCM2.CollaborationPortalRAController.getTeamCategories(params.teamMemberId, params.team, function(result, event){
							  //alert('status = ' + status);
							  if(event.status) {
								  deferred.resolve(result);
							  } else {
								  deferred.reject('Fetch categories failed');
							  }
							  LoadingNotifyService.finishedLoading();
						  }, {escape: false});
					  }

					  LoadingNotifyService.startLoading();

					  return {$promise: deferred.promise};
		  */
        },
      clear: function() {
        categoriesCache = undefined;
      },
      categoriesCleared: function(teamOrTeamMember) {
        return categoriesWasSet && (!categoriesCache || !categoriesCache[teamOrTeamMember] || !categoriesCache[teamOrTeamMember].categories);
      }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ContactFactory', ['$q', 'LoadingNotifyService', '$window', '$timeout', '$log', function ($q, LoadingNotifyService, $window, $timeout, $log) {
	var contactsCache;

	if ($window.contacts) {
		$log.debug('initialised with contacts');
		contactsCache = $window.contacts;
	}

	return {
        query: function(params) {
            var deferred = $q.defer();

            var search = params.search;
            if (!search) {
                search = '';
            }

            var group = params.group;
            if (!group) {
                group = '';
            }

			if (contactsCache && search == '' && group == '') {
				$timeout(function() {deferred.resolve(contactsCache)}, 0);
			} else {

				fHCM2.CollaborationPortalRAController.getContacts(search, group, function (result, event) {
					//alert('status = ' + status);
					if (event.status) {
						deferred.resolve(result);
					} else {
						deferred.reject('Fetch contacts failed');
					}
					LoadingNotifyService.finishedLoading('ContactFactory');
				}, {escape: false});
				LoadingNotifyService.startLoading('ContactFactory');
			}

			return {$promise: deferred.promise};
        }
    };

}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ContextFactory', ['UserFactory', 'ViewPortFactory', 'CategoryFactory', '$route', '$location', '$timeout', '$log',
	function (UserFactory, ViewPortFactory, CategoryFactory, $route, $location, $timeout, $log) {

		function addReportingRelationships(viewport) {
			angular.forEach(viewport.directReports, function (teamMember) {
				teamMember.reportingRelationship = 'fHCM2__Global_Direct_Report';
			});
			angular.forEach(viewport.crossReports, function (teamMember) {
				teamMember.reportingRelationship = 'fHCM2__Global_Cross_Report';
			});
			angular.forEach(viewport.colleagues, function (teamMember) {
				teamMember.reportingRelationship = 'fHCM2__Global_Colleague';
			});
			angular.forEach(viewport.Managers, function (teamMember) {
				teamMember.reportingRelationship = 'fHCM2__Global_Manager';
			});
		}

		var currentContext = {
			onChangeHandlers: [],
			callWhenLoaded: function(handler) {
				if (currentContext.teamMemberId) {
					if (currentContext.onChangeHandlers.length == 0) {
						$timeout(function () {
							$log.debug('ContextFactory: timeout fired');
							currentContext.changed();
						});
					}
				}

				return currentContext.registerCallWhenChanged(handler);
			},
			registerCallWhenChanged: function(handler) {
				currentContext.onChangeHandlers.push(handler);
				return currentContext.onChangeHandlers.length - 1;
			},
			unregisterCallWhenChanged: function(index) {
				currentContext.onChangeHandlers[index] = undefined;
			},
			changed: function() {
				function setQuarters(res) {
					res.options.forEach(function (option) {
						currentContext.teamMember[option.name] = option.value;
					});
				}

				if (currentContext.teamMember.quarters) {
					setQuarters(currentContext.teamMember.quarters);
				}

				angular.forEach(currentContext.onChangeHandlers, function(handler, index) {
					if (handler) {
						handler(currentContext);
					}
				});

				// discard callbacks
				currentContext.onChangeHandlers.length = 0;
			},
			selectTeamMember: function(teamMemberId, redirectToLandingPage, force) {
				function redirect() {
					$log.debug('Setting route for team member ' + teamMemberId);

					var params = {teamMemberId: teamMemberId};
					var categoryItems = CategoryFactory.query(params);
					categoryItems.$promise.then(function (result) {

						categoryItems = result;

						$log.debug('setting page url');

						// change the route to point to the default category
						// this is the one with the lowest order

						//if (result && result.length > 0) {
						if (categoryItems && categoryItems.length > 0) {
							var selectedItem;
							categoryItems.forEach(function (categoryItem) {
								if (!selectedItem || categoryItem.order < selectedItem.order) {
									selectedItem = categoryItem;
								}
							});

							$location.path('/teammember/' + teamMemberId + '/services/' + selectedItem.id);
						} else {
							$log.debug("Unable to set service");
							$location.path('/teammember/' + teamMemberId);
						}
					}, function () {
						$log.debug('get services failed');
					});

				}

				if (teamMemberId != currentContext.teamMemberId || force) {


					if (teamMemberId != currentContext.teamMemberId) {
						currentContext.teamMember = ViewPortFactory.get({teamMemberId: teamMemberId});
						currentContext.teamMember.$promise.then(function (result) {
							$log.debug('ContextFactory: team member changed');
							currentContext.teamMemberId = result.teamMember.id;
							currentContext.teamMember = result;

							addReportingRelationships(result);

							currentContext.changed();

							if (redirectToLandingPage) {
								redirect();
							}
						});
					} else {
						if (redirectToLandingPage) {
							redirect();
						}
					}
				}
			},
			getTeamMembers: function (teamName) {
				if (currentContext.teamMember) {
					switch (teamName) {
						case 'Direct Reports':
							return currentContext.teamMember.directReports;
						case 'Cross Reports':
							return currentContext.teamMember.crossReports;
						case 'Colleagues':
							return currentContext.teamMember.colleagues;
						case 'All Reports':
							if (currentContext.teamMember.directReports) {
								if (currentContext.teamMember.crossReports) {
									return currentContext.teamMember.directReports.concat(currentContext.teamMember.crossReports);
								} else {
									return currentContext.teamMember.directReports.slice(0);
								}
							} else {
								if (currentContext.teamMember.crossReports) {
									return currentContext.teamMember.crossReports.slice(0);
								} else {
									return null;
								}
							}
						default:
							var teamMembers = [];
							if (currentContext.teamMember.Managers) {
								teamMembers = teamMembers.concat(currentContext.teamMember.Managers);
							}
							if (currentContext.teamMember.directReports) {
								teamMembers = teamMembers.concat(currentContext.teamMember.directReports);
							}
							if (currentContext.teamMember.crossReports) {
								teamMembers = teamMembers.concat(currentContext.teamMember.crossReports);
							}
							if (currentContext.teamMember.colleagues) {
								teamMembers = teamMembers.concat(currentContext.teamMember.colleagues);
							}

							return teamMembers;
					}
				}

				return undefined;
			},
			setYourPath: function(teamMemberId, category, process) {
				$log.debug('setYourPath in ContextFactory');

				if (!category) {
					$log.debug('Undefined category');
					return;
				}

				var path = '/services/' + category;
				if (process) {
					path += '/processes/' + process;
				}

				$log.debug('user = ' + teamMemberId + ' context = ' + currentContext.teamMemberId);
				if (teamMemberId != currentContext.teamMemberId) {
					$log.debug('switching back to new team member');

					currentContext.registerCallWhenChanged(function() {
						$location.path('/teammember/' + currentContext.teamMemberId + path);
					});

					currentContext.selectTeamMember(teamMemberId, false);
				} else {
					$location.path('/teammember/' + currentContext.teamMemberId + path);
				}
			},

			setYourOtherPath: function(teamMemberId, process) {
				$log.debug('setYourOtherPath in ContextFactory');

				if (!process) {
					$log.debug('Undefined process');
					return;
				}

				var path = '/' + process;

				$log.debug('user = ' + teamMemberId + ' context = ' + currentContext.teamMemberId);
				if (teamMemberId != currentContext.teamMemberId) {
					$log.debug('switching back to new team member');

					currentContext.registerCallWhenChanged(function() {

						$location.path('/teammember/' + currentContext.teamMemberId + path);
					});

					currentContext.selectTeamMember(teamMemberId, false);
				} else {
					$location.path('/teammember/' + currentContext.teamMemberId + path);
				}
			},

			setYourTeamPath: function (teamMemberId, teamName, category, process) {
				$log.debug('setYourTeamPath in currentContext');

				if (!teamName) {
					$log.debug('Undefined teamName');
					return;
				}

				if (!category) {
					$log.debug('Undefined category');
					return;
				}

				var path = '/services/' + category;
				if (process) {
					path += '/processes/' + process;
				}

				$log.debug('user = ' + teamMemberId + ' context = ' + currentContext.teamMemberId);
				if (teamMemberId != currentContext.teamMemberId) {
					$log.debug('switching back to another team member');

					currentContext.registerCallWhenChanged(function() {
						$location.path('/teammember/' + teamMemberId + '/team/' + teamName + path);
					});

					currentContext.selectTeamMember(teamMemberId, false);
				} else {

					$location.path('/teammember/' + teamMemberId + '/team/' + teamName + path);
				}
			}
		};


		UserFactory.callWhenLoaded(function(teamMemberId) {
			// need to look at route to see if this is the correct user for the context
			if ($route.current && (!$route.current.params.teamMemberId || $route.current.params.teamMemberId == teamMemberId)) {

				currentContext.teamMemberId = teamMemberId;
				currentContext.teamMember = UserFactory.teamMember; // this is a viewport
				addReportingRelationships(currentContext.teamMember);

				currentContext.changed();
			} else {
				currentContext.selectTeamMember($route.current.params.teamMemberId);
			}
		});

		return currentContext;
	}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('FileFactory', ['$q', 'LoadingNotifyService', 'Utils', function ($q, LoadingNotifyService, Utils) {
  var maxUploadSize = 500000;

  function sendFileInParts(encodedContent, startIndex, params, deferred) {
    var encodedContentPart = encodedContent.substring(startIndex, startIndex + maxUploadSize);

    startIndex = startIndex + maxUploadSize > encodedContent.length ? encodedContent.length : startIndex + maxUploadSize;

    fHCM2.CollaborationPortalRAController.saveFilePartForTeamMember(params.teamMemberId, params.fileName, encodedContentPart, Math.ceil(startIndex / maxUploadSize) - 1, startIndex >= encodedContent.length, function (result, event) {
      if (event.status) {
        if (startIndex >= encodedContent.length) {

          var parsedResult = JSON.parse(result);
          //alert('status = ' + status);
            deferred.resolve(parsedResult);
        } else {
          sendFileInParts(encodedContent, startIndex, params, deferred);
        }
      } else {
        deferred.reject('Save process data failed');
      }
      LoadingNotifyService.finishedLoading('FileFactory');

    }, {escape: false});
    LoadingNotifyService.startLoading('FileFactory');
  }

    function FileFactory() {};

    FileFactory.prototype.$save = function(params) {
		if (!params.teamMemberId) {
			$log.error('no team member specified for file upload');
			return;
		}

		var deferred = $q.defer();
            var file = this.params;

            var reader = Utils.getFileReader();

            reader.onload = function(event) {

              var arr = new Uint8Array(event.target.result);

              var encodedContent = Utils.base64EncArr(arr);

              if (encodedContent.length > maxUploadSize) {
                sendFileInParts(encodedContent, 0, params, deferred);
              } else {
                fHCM2.CollaborationPortalRAController.saveFileForTeamMember(params.teamMemberId, params.fileName, encodedContent, function (result, event) {

                  var parsedResult = JSON.parse(result);
                  //alert('status = ' + status);
                  if (event.status) {
                    deferred.resolve(parsedResult);
                  } else {
                    deferred.reject('Save process data failed');
                  }
                  LoadingNotifyService.finishedLoading('FileFactory');
                }, {escape: false});
                LoadingNotifyService.startLoading('FileFactory');
              };
            }

            reader.readAsArrayBuffer(file);

            return deferred.promise;
        };


    return FileFactory;
}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('FixPictureUrlFactory', [function () {
    return {
		fixsrc: function (img) { /* used by mobile app only - see version of fixpictureurl in mobile/source for details */
		}
	}
}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('HrNoticeCategoryFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    return {
        get: function(params) {
            var deferred = $q.defer();

                fHCM2.CollaborationPortalRAController.getCategoryNoticeboard(params.teamMemberId, params.categoryId, function(result, event){
                    //alert('status = ' + status);
                    if(event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch category failed');
                    }
                    LoadingNotifyService.finishedLoading('HrNoticeCategoryFactory');
                }, {escape: false});

            LoadingNotifyService.startLoading('HrNoticeCategoryFactory');

            return {$promise: deferred.promise};
        }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('HrNoticeFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    return {
        get: function(params) {
            var deferred = $q.defer();

                fHCM2.CollaborationPortalRAController.getProcessNoticeboard(params.teamMemberId, params.processId, function(result, event){
                    //alert('status = ' + status);
                    if(event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch category failed');
                    }
                    LoadingNotifyService.finishedLoading('HrNoticeFactory');
                }, {escape: false});

            LoadingNotifyService.startLoading('HrNoticeFactory');

            return {$promise: deferred.promise};
        }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('LoadingNotifyService', ['$timeout', '$log', '$injector', function ($timeout, $log, $injector) {

        var inProgressCounter = 0;

        var loadingNotifyService = {
            startLoading: function(caller) {
              $log.debug('Started Loading: ' + caller);
                inProgressCounter++;

                if (loadingNotifyService.timeout) {
                    $timeout.cancel(loadingNotifyService.timeout);
                }

                loadingNotifyService.timeout = $timeout(function() {
                  $log.warn('Loading timeout fired. Pending = ' + inProgressCounter);
                    inProgressCounter = 0;
                    loadingNotifyService.timeout = undefined;

					var dataFactory = $injector.get('ProcessDataFactory');
					if (dataFactory) {
						dataFactory.timeout();
					}
                }, 20000);
            },
            finishedLoading: function(caller) {
              $log.debug('Finished Loading: ' + caller);
                if (inProgressCounter > 0) {
                    inProgressCounter--;

                  if (inProgressCounter == 0 && loadingNotifyService.timeout) {
                    $timeout.cancel(loadingNotifyService.timeout);
                    loadingNotifyService.timeout = undefined;
                  }
                } else {
                    $log.error('Attempt to count below zero')
                }
            },
            isLoading: function () {
                return inProgressCounter > 0;
            }
        };

        return loadingNotifyService;
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('LocaleFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    function LocaleFactory() {};

    LocaleFactory.prototype.$save = function(params) {
            var deferred = $q.defer();

            fHCM2.CollaborationPortalRAController.setLocale((this.params.locale ? this.params.locale : this.params), function(result, event){
                //alert('status = ' + status);
                if(event.status) {
                    deferred.resolve(result);
                } else {
                    deferred.reject('Set locale failed');
                }
                LoadingNotifyService.finishedLoading('LocaleFactory');
            }, {escape: false});
            LoadingNotifyService.startLoading('LocaleFactory');
            return deferred.promise;
        };

    return LocaleFactory;
}]);

/* EOF */
angular.module('fairsailWX').factory('OperationOptionsFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    function OperationOptionsFactory() {};


    OperationOptionsFactory.query = function(params) {
        var deferred = $q.defer();
        var fieldId = params.fieldId ? params.fieldId : '';

        var options = {};
        options.itemId = params.itemId ? params.itemId : '';
        options.partial = params.partial ? params.partial : '';
        options.dependentFieldId = params.dependentFieldId ? params.dependentFieldId : '';
        options.dependentFieldValue = params.dependentFieldValue ? params.dependentFieldValue : '';

            fHCM2.CollaborationPortalRAController.getOperationOptions(params.teamMemberId, params.processId, params.operationId, fieldId,  options, function (result, event) {
                //alert('status = ' + status);
                if (event.status) {
                    deferred.resolve(result);
                } else {
                    deferred.reject('Fetch operation options failed');
                }
                LoadingNotifyService.finishedLoading('OperationOptionsFactory');
            }, {escape: false});
        LoadingNotifyService.startLoading('OperationOptionsFactory');

        return {$promise: deferred.promise};
    };

    return OperationOptionsFactory;
}]);


/* EOF */
'use strict';

angular.module('fairsailWX').factory('OrgChartFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    return {
        get: function(params) {
            var deferred = $q.defer();

            var teamMemberId = params.teamMemberId;
            if (!teamMemberId) {
                return undefined;
            }

          var options = {};

          options.level = params.level ? params.level : '';

            fHCM2.CollaborationPortalRAController.getOrgChartWithLevels(teamMemberId, options, function(result, event){
                //alert('status = ' + status);
                if(event.status) {
                    deferred.resolve(result);
                } else {
                    deferred.reject('Fetch org chart failed');
                }
                LoadingNotifyService.finishedLoading('OrgChartFactory');
            }, {escape: false});

            LoadingNotifyService.startLoading('OrgChartFactory');
            return {$promise: deferred.promise};
        }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('pickadateUtils', ['dateFilter', function(dateFilter) {
    return {
        isDate: function(obj) {
            return Object.prototype.toString.call(obj) === '[object Date]';
        },

        stringToDate: function(dateString) {
			if (!dateString) return null;

            if (this.isDate(dateString)) return new Date(dateString);
            var dateParts = dateString.split('-'),
                year  = dateParts[0],
                month = dateParts[1],
                day   = dateParts[2];

            // set hour to 3am to easily avoid DST change
            return new Date(year, month - 1, day);
        },

        dateRange: function(first, last, initial, format) {
            var date, i, _i, dates = [];

            if (!format) format = 'yyyy-MM-dd';

            for (i = _i = first; first <= last ? _i < last : _i > last; i = first <= last ? ++_i : --_i) {
                date = this.stringToDate(initial);
                date.setDate(date.getDate() + i);
                dates.push(dateFilter(date, format));
            }
            return dates;
        }
    };
}]);
/* EOF */
'use strict';

angular.module('fairsailWX').factory('ProcessDataFactory', ['$q', 'LoadingNotifyService', '$log', function ($q, LoadingNotifyService, $log) {

	var defers = [];

    function ProcessDataFactory() {};

        ProcessDataFactory.prototype.$save = function(params) {
            var deferred = $q.defer();
            var options = {};
            options.itemId = params.itemId ? params.itemId : '';
            options.childId = params.childId ? params.childId : '';
            options.fieldGroupName = params.fieldGroupName ? params.fieldGroupName : '';

            var data;
            if (this.params) {
                data = JSON.stringify(this.params);
            } else {
                data = '';
            }

            fHCM2.CollaborationPortalRAController.doOperationData(params.teamMemberId, params.processId, params.dataId, options, data, function(result, event) {

                var parsedResult = JSON.parse(result);
                //alert('status = ' + status);
                if(event.status) {
                    deferred.resolve(parsedResult);
                } else {
					$log.error('Save failed');

					// inject dummy result
					deferred.resolve({
						result: true,
						refresh: 'process_and_actions',
						errors:[{
							message: 'There was a problem communicating with the server. Please retry.'
						}]
					});

					//deferred.reject('Save process data failed');
                }

				defers.pop();

                LoadingNotifyService.finishedLoading('ProcessDataFactory');
            }, {escape: false});
            LoadingNotifyService.startLoading('ProcessDataFactory');

			defers.push(deferred);

            return deferred.promise;
        };

	ProcessDataFactory.timeout = function () {
		$log.warn('Save timeout');

		angular.forEach(defers, function (deferred) {
			// inject dummy result
			deferred.resolve({
				result: true,
				refresh: 'process_and_actions',
				warnings:[{
					message: 'There was a problem communicating with the server. Please retry.'
				}]
			});
		});

		defers.length = 0;
	}

    ProcessDataFactory.query = function(params) {
        var deferred = $q.defer();

        if (params.dataType == 'views') {
            var options = {};
            options.itemId = params.itemId ? params.itemId : '';
            options.startYear = params.startYear ? params.startYear : '';
            options.startYearOffset = params.startYearOffset ? params.startYearOffset : '';

            if (params.team) {
                fHCM2.CollaborationPortalRAController.getTeamProcessViewData(params.teamMemberId, params.team, params.processId, params.dataId, options, function (result, event) {
                    var parsedResult = JSON.parse(result);
                    if (event.status) {
                        deferred.resolve(parsedResult);
                    } else {
                        deferred.reject('Fetch view data failed');
                    }
                  LoadingNotifyService.finishedLoading('ProcessDataFactory');
                }, {escape: false});
            } else {
                fHCM2.CollaborationPortalRAController.getProcessViewData(params.teamMemberId, params.processId, params.dataId, options, function (result, event) {
                    var parsedResult = JSON.parse(result);
                    if (event.status) {
                        deferred.resolve(parsedResult);
                    } else {
                        deferred.reject('Fetch view data failed');
                    }
                  LoadingNotifyService.finishedLoading('ProcessDataFactory');
                }, {escape: false});
            }
          LoadingNotifyService.startLoading('ProcessDataFactory');
        } else if (params.dataType == 'operations') {
/*
            var options = {};

            options.itemId = params.itemId ? params.itemId : '';
            options.childId = params.childId ? params.childId : '';
            options.fieldGroupName = params.fieldGroupName ? params.fieldGroupName : '';


            fHCM2.CollaborationPortalRAController.getProcessOperationData(params.teamMemberId, params.processId, params.dataId, options, function (result, event) {
            */
            fHCM2.CollaborationPortalRAController.getProcessOperationData(params.teamMemberId, params.processId, params.dataId, params, function (result, event) {
                var parsedResult = JSON.parse(result);
                if (event.status) {
                    deferred.resolve(parsedResult);
                } else {
                    deferred.reject('Fetch operation data failed');
                }
              LoadingNotifyService.finishedLoading('ProcessDataFactory');

            }, {escape: false});
          LoadingNotifyService.startLoading('ProcessDataFactory');
        } else {
            alert('Unable to find data action');
        }

        return {$promise: deferred.promise};
    };


    ProcessDataFactory.get = function(params) {
        var deferred = $q.defer();

        if (params.dataType == 'views') {

            var options = {};
            options.itemId = params.itemId ? params.itemId : '';
            options.startYear = params.startYear ? params.startYear : '';
            options.startYearOffset = params.startYearOffset ? params.startYearOffset : '';
            options.searchString = params.searchString ? params.searchString : '';
            options.page = params.page ? params.page : '';

            if (params.team) {
                fHCM2.CollaborationPortalRAController.getTeamProcessViewData(params.teamMemberId, params.team, params.processId, params.dataId, options, function (result, event) {
                    var parsedResult = JSON.parse(result);
                    if (event.status) {
                        deferred.resolve(parsedResult);
                        LoadingNotifyService.finishedLoading();
                    } else {
                        deferred.reject('Fetch view data failed');
                        LoadingNotifyService.finishedLoading();
                    }
                }, {escape: false});
                LoadingNotifyService.startLoading();
            } else {
                fHCM2.CollaborationPortalRAController.getProcessViewData(params.teamMemberId, params.processId, params.dataId, options, function (result, event) {
                    var parsedResult = JSON.parse(result);
                    if (event.status) {
                        deferred.resolve(parsedResult);
                        LoadingNotifyService.finishedLoading();
                    } else {
                        deferred.reject('Fetch view data failed');
                        LoadingNotifyService.finishedLoading();
                    }
                }, {escape: false});
                LoadingNotifyService.startLoading();
            }
        } else if (params.dataType == 'operations') {
/*
            var options = {};
            options.itemId = params.itemId ? params.itemId : '';
            options.childId = params.childId ? params.childId : '';
            options.fieldGroupName = params.fieldGroupName ? params.fieldGroupName : '';

            fHCM2.CollaborationPortalRAController.getProcessOperationData(params.teamMemberId, params.processId, params.dataId, options, function (result, event) {
*/
            fHCM2.CollaborationPortalRAController.getProcessOperationData(params.teamMemberId, params.processId, params.dataId, params, function (result, event) {
                var parsedResult = JSON.parse(result);
                if (event.status) {
                    deferred.resolve(parsedResult);
                    LoadingNotifyService.finishedLoading();
                } else {
                    deferred.reject('Fetch operation data failed');
                    LoadingNotifyService.finishedLoading();
                }
            }, {escape: false});
            LoadingNotifyService.startLoading();
        } else {
            alert('Unable to find data action');
        }

        return {$promise: deferred.promise};
    };

    return ProcessDataFactory;
}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ProcessFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    return {
        get: function(params) {
            var deferred = $q.defer();

            if (params.team) {
                fHCM2.CollaborationPortalRAController.getTeamProcess(params.teamMemberId, params.team, params.processId, function (result, event) {
                    //alert('status = ' + status);
                    if (event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch process failed');
                    }
                    LoadingNotifyService.finishedLoading('ProcessFactory');
                }, {escape: false});

            } else {
                fHCM2.CollaborationPortalRAController.getProcess(params.teamMemberId, params.processId, function (result, event) {
                    //alert('status = ' + status);
                    if (event.status) {
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Fetch process failed');
                    }
                    LoadingNotifyService.finishedLoading('ProcessFactory');
                }, {escape: false});
            }

            LoadingNotifyService.startLoading('ProcessFactory');

            return {$promise: deferred.promise};
        }
    };

}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('SearchFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

	function SearchFactory(data) {
		this.data = data;
	};

	SearchFactory.prototype.$save = function(params) {
		var deferred = $q.defer();

		if (this.data) {
			this.data = JSON.stringify(this.data);
		} else {
			this.data = '';
		}

		fHCM2.CollaborationPortalRAController.search(params.teamMemberId, {}, this.data, function(result, event){
			var parsedResult = JSON.parse(result);
			//alert('status = ' + status);
			if(event.status) {
				deferred.resolve(parsedResult);
			} else {
				deferred.reject('Search failed');
			}
			LoadingNotifyService.finishedLoading('SearchFactory');
		}, {escape: false});

		LoadingNotifyService.startLoading('SearchFactory');

		return deferred.promise;
	};

	return SearchFactory;

}]);

/* EOF */
angular.module('fairsailWX').factory('SearchOptionsFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {

    function SearchOptionsFactory() {};


	SearchOptionsFactory.get = function(params) {
        var deferred = $q.defer();
        var fieldName = params.fieldName ? params.fieldName : '';

        var options = {};
        options.partial = params.partial ? params.partial : '';
        options.dependentFieldId = params.dependentFieldId ? params.dependentFieldId : '';
        options.dependentFieldValue = params.dependentFieldValue ? params.dependentFieldValue : '';

            fHCM2.CollaborationPortalRAController.getSearchOptions(params.teamMemberId, fieldName,  options, function (result, event) {
                //alert('status = ' + status);
                if (event.status) {
                    deferred.resolve(result);
                } else {
                    deferred.reject('Fetch search options failed');
                }
                LoadingNotifyService.finishedLoading('SearchOptionsFactory');
            }, {escape: false});
        LoadingNotifyService.startLoading('SearchOptionsFactory');

        return {$promise: deferred.promise};
    };

    return SearchOptionsFactory;
}]);


/* EOF */


angular.module('fairsailWX').factory('TranslationLoaderFactory', ['$q', 'LoadingNotifyService', function ($q, LoadingNotifyService) {
    return function (options) {
        var deferred = $q.defer();

        fHCM2.CollaborationPortalRAController.getTranslations(options.key, function(result, event){
            //alert('status = ' + status);
            if(event.status) {
                var translations = JSON.parse(JSON.stringify(result));

				// modify translation parameter substitution
				for (var key in translations) {
					translations[key] = translations[key].replace('{0}', '{{translateParam0}}');
					translations[key] = translations[key].replace('{1}', '{{translateParam1}}');
					translations[key] = translations[key].replace('{2}', '{{translateParam2}}');
				}

				deferred.resolve(translations);
            } else {
                deferred.reject('Fetch translations failed');
            }
            LoadingNotifyService.finishedLoading('TranslationLoaderFactory');
        }, {escape: false});
        LoadingNotifyService.startLoading('TranslationLoaderFactory');
        return deferred.promise;
    }
}]);


/* EOF */
'use strict';

angular.module('fairsailWX').factory('UserFactory', ['ViewPortFactory', '$translate', '$window', '$timeout', function (ViewPortFactory, $translate, $window, $timeout) {

	var currentUser = {
		onLoadHandlers: [],
		callWhenLoaded: function(handler) {
			//console.log('user callback added');
			if (currentUser.teamMemberId) {
				handler(currentUser.teamMemberId);
				/*           } else {
				 currentUser.onLoadHandlers.push(handler);
				 */            }

			currentUser.onLoadHandlers.push(handler);

		},
		loaded: function () {
			currentUser.teamMemberId = currentUser.teamMember.viewerId;
			currentUser.onLoadHandlers.forEach(function(handler) {
				handler(currentUser.teamMemberId);
			});
			//currentUser.onLoadHandlers.length = 0;

			$translate.use(currentUser.teamMember.teamMember.locale);
		},
		reload: function() {
			$window.location.reload();
		},

		isManager: function () {
			return currentUser.teamMember ? (currentUser.teamMember.hasDirectReports == true || currentUser.teamMember.hasCrossReports == true || currentUser.teamMember.isHR == true) : false;
		}
	};

	if ($window.userViewport) {
		currentUser.teamMember = $window.userViewport;

		$timeout(function() {currentUser.loaded()}, 0);
	} else {
		currentUser.teamMember = ViewPortFactory.get({});
		currentUser.teamMember.$promise.then(function (result) {
			currentUser.teamMember = result;
			currentUser.loaded();
		});
	}

	return currentUser;
}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('Utils', ['$filter', '$window', '$log', function ($filter, $window, $log) {

    var utils = {
        isVisible: function (element) {
                return element
                    && element.style.display != 'none'
                    && element.offsetWidth
                    && element.offsetHeight;
        },
        selectTile: function (preferredNumberOfColumns, availableColumns, tiles) {
            if (!preferredNumberOfColumns
                || preferredNumberOfColumns < 1
                || !availableColumns
                || availableColumns < 1
                || !tiles
                || tiles.length == 0) {
                return null;
            }

            var bestFit = 0;
            if (availableColumns >= preferredNumberOfColumns) {
                bestFit = preferredNumberOfColumns;
            } else {
                bestFit = availableColumns;
            }

            var selectedTile;
            for(var i = 0; i < tiles.length; i++) {
                var tile = tiles[i];
                 if (tile.numberOfColumns == bestFit) {
                   return tile;
                } else if (!selectedTile) {
                   selectedTile = tile;
                } else {
                    if (selectedTile.numberOfColumns > bestFit) {
                        if (tile.numberOfColumns < selectedTile.numberOfColumns) {
                            selectedTile = tile;
                        }
                    } else {
                        if (tile.numberOfColumns > selectedTile.numberOfColumns && tile.numberOfColumns < bestFit) {
                            selectedTile = tile;
                        }
                    }
                }
            };

            // pick first tile if none set as default
            if (!selectedTile) {
                selectedTile = res.tiles[0];
            }

            return selectedTile;
        },
        getNumberOfColumnsAvailable: function(displayMode) {
            switch(displayMode) {
                case 'mobile':
                    return 1;
                case 'tablet':
                    return 2;
                case 'tablet-landscape':
                    return 3;
                case 'laptop':
                    return 3;
                case 'desktop':
                    return 4;
                default:
                    return 1;
            }
        },
        getNumberOfPeopleColumnsAvailable: function(displayMode) {
            switch(displayMode) {
                case 'mobile':
                    return 1;
                case 'tablet':
                    return 2;
                case 'tablet-landscape':
                    return 2;
                case 'laptop':
                    return 2;
                case 'desktop':
                    return 3;
                default:
                    return 1;
            }
        },

        sortTilesIntoColumns: function(processes, displayMode) {
            var rows = [];

            var columns = utils.getNumberOfColumnsAvailable(displayMode);

            if (columns < 1) {
                $log.error('Invalid number of columns');
              columns = 1;
            }

            var orderedProcesses = $filter('orderBy')(processes, 'order');

            var usedColumns = 0;
            angular.forEach(orderedProcesses, function (process) {
                if ((usedColumns == 0) || (columns - usedColumns < process.numberOfColumns)) {
                    rows[rows.length] = [];
                    usedColumns = 0;
                }

                rows[rows.length - 1][rows[rows.length - 1].length] = process;

                usedColumns += process.numberOfColumns;

                if (usedColumns >= columns) {
                    usedColumns = 0;
                }
            });

            return rows;
        },
        sortPeopleIntoColumns: function(people, displayMode) {
            var rows = [];

            var columns = utils.getNumberOfPeopleColumnsAvailable(displayMode);

            if (columns < 1) {
                $log.error('Invalid number of columns');
              columns = 1;
            }

            var usedColumns = 0;
            angular.forEach(people, function (person) {
                if (usedColumns == 0) {
                    rows[rows.length] = [];
                    usedColumns = 0;
                }

                rows[rows.length - 1][rows[rows.length - 1].length] = person;

                usedColumns ++;

                if (usedColumns >= columns) {
                    usedColumns = 0;
                }
            });

            return rows;

        },

        getElementById: function (id) {
            return document.getElementById(id);
        },
        getFileReader: function () {
            return new FileReader();
        },
        findBySelector: function (selector) {
            return $(selector);
        },

        /*\
         |*|
         |*|  Base64 / binary data / UTF-8 strings utilities
         |*|
         |*|  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Base64_encoding_and_decoding
         |*|
         \*/

        /* Array of bytes to base64 string decoding */

        b64ToUint6: function (nChr) {

            return nChr > 64 && nChr < 91 ?
                nChr - 65
                : nChr > 96 && nChr < 123 ?
                nChr - 71
                : nChr > 47 && nChr < 58 ?
                nChr + 4
                : nChr === 43 ?
                62
                : nChr === 47 ?
                63
                :
                0;

        },

        base64DecToArr: function (sBase64, nBlocksSize) {

            var
                sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
                nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 + 1 >> 2, taBytes = new Uint8Array(nOutLen);

            for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
                nMod4 = nInIdx & 3;
                nUint24 |= utils.b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 18 - 6 * nMod4;
                if (nMod4 === 3 || nInLen - nInIdx === 1) {
                    for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
                        taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
                    }
                    nUint24 = 0;

                }
            }

            return taBytes;
        },

        /* Base64 string to array encoding */

        uint6ToB64: function (nUint6) {

            return nUint6 < 26 ?
                nUint6 + 65
                : nUint6 < 52 ?
                nUint6 + 71
                : nUint6 < 62 ?
                nUint6 - 4
                : nUint6 === 62 ?
                43
                : nUint6 === 63 ?
                47
                :
                65;

        },

        base64EncArr: function (aBytes) {

            var nMod3 = 2, sB64Enc = "";

            for (var nLen = aBytes.length, nUint24 = 0, nIdx = 0; nIdx < nLen; nIdx++) {
                nMod3 = nIdx % 3;
                if (nIdx > 0 && (nIdx * 4 / 3) % 76 === 0) { sB64Enc += "\r\n"; }
                nUint24 |= aBytes[nIdx] << (16 >>> nMod3 & 24);
                if (nMod3 === 2 || aBytes.length - nIdx === 1) {
                    sB64Enc += String.fromCharCode(utils.uint6ToB64(nUint24 >>> 18 & 63), utils.uint6ToB64(nUint24 >>> 12 & 63), utils.uint6ToB64(nUint24 >>> 6 & 63), utils.uint6ToB64(nUint24 & 63));
                    nUint24 = 0;
                }
            }

            return sB64Enc.substr(0, sB64Enc.length - 2 + nMod3) + (nMod3 === 2 ? '' : nMod3 === 1 ? '=' : '==');

        },

        /* UTF-8 array to DOMString and vice versa */

        UTF8ArrToStr: function (aBytes) {

            var sView = "";

            for (var nPart, nLen = aBytes.length, nIdx = 0; nIdx < nLen; nIdx++) {
                nPart = aBytes[nIdx];
                sView += String.fromCharCode(
                        nPart > 251 && nPart < 254 && nIdx + 5 < nLen ? /* six bytes */
                        /* (nPart - 252 << 32) is not possible in ECMAScript! So...: */
                        (nPart - 252) * 1073741824 + (aBytes[++nIdx] - 128 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
                        : nPart > 247 && nPart < 252 && nIdx + 4 < nLen ? /* five bytes */
                        (nPart - 248 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
                        : nPart > 239 && nPart < 248 && nIdx + 3 < nLen ? /* four bytes */
                        (nPart - 240 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
                        : nPart > 223 && nPart < 240 && nIdx + 2 < nLen ? /* three bytes */
                        (nPart - 224 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
                        : nPart > 191 && nPart < 224 && nIdx + 1 < nLen ? /* two bytes */
                        (nPart - 192 << 6) + aBytes[++nIdx] - 128
                        : /* nPart < 127 ? */ /* one byte */
                        nPart
                );
            }

            return sView;

        },

        strToUTF8Arr: function (sDOMStr) {

            var aBytes, nChr, nStrLen = sDOMStr.length, nArrLen = 0;

            /* mapping... */

            for (var nMapIdx = 0; nMapIdx < nStrLen; nMapIdx++) {
                nChr = sDOMStr.charCodeAt(nMapIdx);
                nArrLen += nChr < 0x80 ? 1 : nChr < 0x800 ? 2 : nChr < 0x10000 ? 3 : nChr < 0x200000 ? 4 : nChr < 0x4000000 ? 5 : 6;
            }

            aBytes = new Uint8Array(nArrLen);

            /* transcription... */

            for (var nIdx = 0, nChrIdx = 0; nIdx < nArrLen; nChrIdx++) {
                nChr = sDOMStr.charCodeAt(nChrIdx);
                if (nChr < 128) {
                    /* one byte */
                    aBytes[nIdx++] = nChr;
                } else if (nChr < 0x800) {
                    /* two bytes */
                    aBytes[nIdx++] = 192 + (nChr >>> 6);
                    aBytes[nIdx++] = 128 + (nChr & 63);
                } else if (nChr < 0x10000) {
                    /* three bytes */
                    aBytes[nIdx++] = 224 + (nChr >>> 12);
                    aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
                    aBytes[nIdx++] = 128 + (nChr & 63);
                } else if (nChr < 0x200000) {
                    /* four bytes */
                    aBytes[nIdx++] = 240 + (nChr >>> 18);
                    aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
                    aBytes[nIdx++] = 128 + (nChr & 63);
                } else if (nChr < 0x4000000) {
                    /* five bytes */
                    aBytes[nIdx++] = 248 + (nChr >>> 24);
                    aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
                    aBytes[nIdx++] = 128 + (nChr & 63);
                } else /* if (nChr <= 0x7fffffff) */ {
                    /* six bytes */
                    aBytes[nIdx++] = 252 + (nChr >>> 30);
                    aBytes[nIdx++] = 128 + (nChr >>> 24 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
                    aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
                    aBytes[nIdx++] = 128 + (nChr & 63);
                }
            }

            return aBytes;

        },
        orderFieldSet: function (fieldSet) {
            var orderedList = [];

            if (fieldSet.valueAttributes && fieldSet.optionAttributes) {
                var i = 0, j = 0, done = false;

                while (!done) {
                    if (i < fieldSet.valueAttributes.length && j < fieldSet.optionAttributes.length) {
                        if (fieldSet.valueAttributes[i].order <= fieldSet.optionAttributes[j].order) {
                            orderedList.push(fieldSet.valueAttributes[i++]);
                        } else {
                            orderedList.push(fieldSet.optionAttributes[j++]);
                        }
                    } else if (i < fieldSet.valueAttributes.length) {
                        orderedList.push(fieldSet.valueAttributes[i++]);
                    } else if (j < fieldSet.optionAttributes.length) {
                        orderedList.push(fieldSet.optionAttributes[j++]);
                    } else {
                        done = true;
                    }
                }
            } else if (fieldSet.valueAttributes) {
                var i = 0, done = false;

                while (!done) {
                    if (i < fieldSet.valueAttributes.length) {
                        orderedList.push(fieldSet.valueAttributes[i++]);
                    } else {
                        done = true;
                    }
                }
            } else if (fieldSet.optionAttributes) {
                var i = 0, done = false;

                while (!done) {
                    if (i < fieldSet.optionAttributes.length) {
                        orderedList.push(fieldSet.optionAttributes[i++]);
                    } else {
                        done = true;
                    }
                }
            }

            return orderedList;
        },
        combineFieldSets: function (oldFieldSet, newFieldSet) {
            if (!oldFieldSet || !newFieldSet) {
                return [];
            }

            var oldOrderedList = utils.orderFieldSet(oldFieldSet);
            var newOrderedList = utils.orderFieldSet(newFieldSet);

            if (!oldOrderedList || !newOrderedList || oldOrderedList.length != newOrderedList.length) {
                return [];
            }

            var combinedFieldSets = [];

            for (var i = 0; i < oldOrderedList.length; i++) {
                combinedFieldSets[i] = {
                    oldValue: oldOrderedList[i],
                    newValue: newOrderedList[i]
                };
            }

            return combinedFieldSets;
        },
        combineAllFieldSets: function (oldFieldSets, newFieldSets) {
            if (!oldFieldSets || !newFieldSets) {
                return [];
            }

            var combinedFieldSets = [];

            for (var i = 0; i < oldFieldSets.length; i++) {
                combinedFieldSets = combinedFieldSets.concat(utils.combineFieldSets(oldFieldSets[i], newFieldSets[i]));
            }

            return combinedFieldSets;
        },
      getInternetExplorerVersion: function ()
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
  {

    $log.debug('$window.navigator.appName = ' + $window.navigator.appName);

    var rv = -1; // Return value assumes failure.
    if ($window.navigator.appName == 'Microsoft Internet Explorer')
    {
      $log.debug('$window.navigator.userAgent = ' + $window.navigator.userAgent);
      var ua = $window.navigator.userAgent;
      var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
      if (re.exec(ua) != null)
        rv = parseFloat( RegExp.$1 );
    }
    return rv;
  },
		createSlider: function (id, ticks, tick_labels, initialValue, ticks_snap_bounds) {
			try {
				return angular.element(id).slider({
					ticks: ticks,
					ticks_labels: tick_labels,
					value: initialValue,
					tooltip: 'hide',
					ticks_snap_bounds: ticks_snap_bounds
				});
			} catch (e) {
				$log.error('error' + e);
			}

		},
		userFriendlyDateFormat: function (format) {
			if (format) {
				var parts = format.split('/');

				if (parts.length == 1) return format;

				var result = '';
				angular.forEach(parts, function (part) {
					if (part.toLowerCase().indexOf('d') >= 0) {
						result = result + (result.length > 0 ? '/' : '') + 'DD';
					} else if (part.toLowerCase().indexOf('m') >= 0) {
						result = result + (result.length > 0 ? '/' : '') + 'MM';
					} else if (part.toLowerCase().indexOf('y') >= 0) {
						result = result + (result.length > 0 ? '/' : '') + 'YYYY';
					}
				});

				return result;
			}
			return '';
		}


};

return utils;
}]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ViewPortFactory', ['$q', '$timeout', 'LoadingNotifyService', '$window', function ($q, $timeout, LoadingNotifyService, $window) {
	var userViewport;

	if ($window.userViewport) {
		userViewport = $window.userViewport;
	}

    return {
        get: function(params) {
            var deferred = $q.defer();

			if (userViewport && (userViewport.teamMember.id == params.teamMemberId || !params.teamMemberId)) {
				$timeout(function() {
					deferred.resolve(userViewport);
				}, 0);
				return {$promise: deferred.promise};
			}

			var teamMemberId = params.teamMemberId;
            if (!teamMemberId) {
				teamMemberId = '';
            }

            fHCM2.CollaborationPortalRAController.getActiveOnlyViewport(teamMemberId, function(result, event){
                //alert('status = ' + status);
                if(event.status) {
                    deferred.resolve(result);
                } else {
                    deferred.reject('Fetch viewport failed');
                }
                LoadingNotifyService.finishedLoading('ViewPortFactory');

              $timeout.cancel(deferred.timeout);
            }, {escape: false});

            LoadingNotifyService.startLoading('ViewPortFactory');

            deferred.timeout = $timeout(function () {
              deferred.reject('Failed');
              LoadingNotifyService.finishedLoading('ViewPortFactory');
            }, 10000);

            return {$promise: deferred.promise};
        }
    }
  }]);

/* EOF */
'use strict';

angular.module('fairsailWX').factory('ViewsService', ['$log', function ($log) {

  var hasTeamView = false;
  var hasTeamMemberView = false;

        var viewsService = {
          hasTeamView: function (flag) {
            if (flag != undefined) {
              hasTeamView = flag;
            }
            return hasTeamView;
          },
          hasTeamMemberView: function (flag) {
            if (flag != undefined) {
              hasTeamMemberView = flag;
            }
            return hasTeamMemberView;
          }
        };

        return viewsService;
  }]);
