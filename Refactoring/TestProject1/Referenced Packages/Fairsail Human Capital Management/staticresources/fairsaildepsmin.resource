* {
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
  border-radius: 0;
}
.org-chart-content * {
  position: relative;
}
.org-chart-content * {
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
}
div.org-chart,
div.org-chart-content {
  margin-top: 0px;
}
/* Generic styling */
.orgchart-user-details {
  position: relative;
  padding: 0;
}
.orgchart-user-details:after {
  clear: both !important;
}
.orgchart-user-details .orgchart-user-image {
  position: absolute;
  z-index: 1;
  top: -15px;
  width: 100%;
  text-align: left;
}
.orgchart-user-image img {
  clear: both;
  margin: auto;
  position: relative;
  height: 50px;
  width: 50px;
  cursor: pointer;
  transition: .4s;
  border: solid 1px #D5DEE7;
}
.orgchart-user-image img:hover {
  border: solid 5px #D5DEE7;
}
.orgchart-user-details .orgchart-user-info-block {
  width: 100%;
  position: relative;
  padding-left: 15px;
  /*background: rgb(255, 255, 255);*/
  z-index: 0;
  padding-top: 0px;
}
.orgchart-user-info-block .orgchart-user-heading {
  width: 100%;
  text-align: left;
  margin-top: 10px;
  margin-right: 0px;
  margin-bottom: 0px;
  margin-left: 0px;
  padding-left: 40px;
  background-color: #D5DEE7;
}
.orgchart-user-info-block .orgchart-user-heading h3 {
  margin: 0px;
  padding-top: 8px;
  padding-bottom: 8px;
  text-transform: uppercase;
  font-size: small;
}
.orgchart-user-info-block .orgchart-user-body {
  float: left;
  padding-bottom: 5px;
  padding-left: 15px;
  padding-top: 5px;
  width: 100%;
  font-size: smaller;
  background-color: #FFFFFF;
  border: solid 1px #D5DEE7;
}
.orgchart-user-info-block .orgchart-navigation-team {
  float: left;
  width: 100%;
  margin: 0;
  padding: 0;
  font-size: smaller;
  border-bottom: 1px solid #D5DEE7;
  border-right: 1px solid #D5DEE7;
  border-left: 1px solid #D5DEE7;
  /* border-top: 1px solid #D5DEE7; */
  background-color: #FFFFFF;
  text-transform: uppercase;
  color: #A9C0C9;
  margin-top: -2px;
  text-align: right;
  padding-right: 10px;
  cursor: pointer;
  font-weight: bold;
}
.orgchart-user-info-block .orgchart-navigation-team span {
  padding: 5px;
  background-color: #D5DEE7;
  color: #666;
  /* border: solid 1px #D5DEE7; */
  border-top-color: #d5dee7;
  border-top-style: solid;
  border-top-width: 1px;
  border-right-color: #d5dee7;
  border-right-style: solid;
  border-right-width: 1px;
  /* border-bottom-color: rgb(213, 222, 231); */
  /* border-bottom-style: solid; */
  /* border-bottom-width: 1px; */
  border-left-color: #d5dee7;
  border-left-style: solid;
  border-left-width: 1px;
}
.orgchart-user-info-block .orgchart-navigation-team span:hover {
  color: #000;
}
.orgchart-user-info-block .orgchart-navigation-team span img {
  margin-top: -2px;
}
.orgchart-user-info-block .fade-div {
  float: left;
  width: 100%;
  margin: 0;
  padding: 0;
  font-size: smaller;
  border-bottom: 1px solid #D5DEE7;
  border-top: 1px solid #D5DEE7;
}
/*.fade-div.ng-hide-add,*/
/*.fade-div.ng-hide-remove {*/
/*-webkit-transition: all linear 0.5s;*/
/*transition: all linear 0.5s;*/
/*display:block!important;*/
/*overflow: hidden;*/
/*//height: 200px;*/
/*transition: height 1s ease-in-out;*/
/*-webkit-transition: height 1s ease-in-out;*/
/*}*/
/*.fade-div.ng-hide {*/
/*line-height: 0;*/
/*opacity: 0;*/
/*padding: 0 ;*/
/*overflow: hidden;*/
/*height: 0px;*/
/*transition: height 1s ease-in-out;*/
/*-webkit-transition: height 1s ease-in-out;*/
/*}*/
.org-name,
.org-info,
.org-manager-label,
.org-report-label,
.org-name-subject,
.org-cross-manager-label {
  line-height: 1.4em;
  text-align: left;
  margin-left: 30px;
  padding-left: 37px;
}
.org-name,
.org-name-subject {
  font-weight: bold;
  margin-bottom: 3px;
  margin-top: 5px;
}
.org-name-subject {
  margin-top: 0;
}
.org-manager-label,
.org-cross-manager-label {
  color: #ffffff;
  background-color: #00529f;
  padding: 4px 0px 4px 35px;
  margin-top: -10px;
  font-weight: bold;
}
.org-cross-manager-label {
  margin: 10px 0 15px 5%;
  text-transform: uppercase;
  font-size: 13px;
  float: left;
  padding: 5px;
}
.org-report-label {
  padding: 4px 0px 4px 35px;
  margin-top: -10px;
  border-bottom: 1px solid #d5dee7;
  font-weight: bold;
  background-color: #d5dee7;
}
.org-info {
  line-height: 1.4em;
}
.org-image {
  height: 80px;
  width: 80px;
  /*    margin-left: 20px;
      margin-top: -5px;*/
  margin-left: -22px;
  margin-top: -16px;
}
.org-team-image {
  height: 50px;
  width: 50px;
  margin-left: -21px;
  margin-top: -15px;
}
.org-chart .panel-group .panel {
  overflow: visible !important;
}
.org-chart .panel-heading {
  padding: 0;
}
.org-manager .org-image,
.org-report .org-image,
.org-team-image,
.org-primary-manager .org-image {
  border: 2px solid #d5dee7 !important;
}
.content {
  width: 100%;
  max-width: 1142px;
  margin: 0 auto;
  padding: 0 20px;
}
/*div.org-report {
    padding: 0;
    margin: 0 0 -30px 0;
}*/
div.org-manager-container,
div.org-reports-container {
  overflow: visible;
  height: 1%;
}
div.org-team-member {
  padding-top: 10px;
  display: block;
  background: #ffffff;
  border: 1px solid #d5dee7;
  border-bottom-width: 4px;
  /*    overflow: hidden;*/
  text-decoration: none;
  color: #000000;
  margin-left: 5%;
  text-transform: uppercase;
  font-size: 13px;
  /*    width: 90%;*/
  min-height: 70px;
  /*
      height: 70px;
  */
}
div.org-primary-manager a {
  margin: 0;
}
.org-chart a.accordion-toggle {
  padding-top: 0;
  margin-left: auto !important;
  margin-right: auto;
  border: none !important;
}
.org-chart .accordion-toggle img.org-contact-hidden,
.org-chart .accordion-toggle span.org-contact-hidden {
  float: right;
  bottom: 32px;
  right: 5%;
  padding: 8px 7px;
  border: solid 2px #d5dee7;
  color: #a9c0c9;
  text-transform: uppercase;
  font-size: 13px;
}
.org-chart .accordion-toggle img.org-contact-shown,
.org-chart .accordion-toggle span.org-contact-shown {
  float: right;
  bottom: 30px;
  right: 5%;
  padding: 11px 7px;
  border: solid 2px #d5dee7;
  color: #a9c0c9;
  text-transform: uppercase;
  font-size: 13px;
}
.org-chart .accordion-toggle span.org-contact-shown {
  padding: 8px 7px;
}
.org-team-name {
  padding-left: 40px;
  padding-right: 35px;
}
.org-team-members {
  width: 100%;
}
div.org-subject {
  margin-bottom: 0;
  color: #ffffff;
  border-bottom-width: 4px;
  display: block;
  margin-left: auto;
  margin-right: auto;
  /*width: 25%;*/
}
.org-subject div.orgchart-user-heading,
.org-subject div.orgchart-user-body {
  background-color: #00529f;
}
.org-primary-manager div.orgchart-user-heading {
  background-color: #00529f;
}
div.org-primary-manager {
  display: block;
  margin-left: auto;
  margin-right: auto;
  /*width: 25%;*/
  padding-bottom: 10px;
}
.org-manager,
.org-report {
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 0px;
}
.org-vertical-connector {
  height: 20px;
  width: 4px;
  background-color: #d5dee7;
  margin-left: auto;
  margin-right: auto;
}
.org-chart .org-reports-container,
.org-chart .org-manager-container {
  border: 4px solid #d5dee7;
  background-color: #ffffff;
  padding-top: 30px;
  /*    text-align: center;*/
  /*    padding-bottom: 30px;*/
}
.org-chart .org-manager-container {
  padding-bottom: 20px;
}
.org-team-list {
  width: 100%;
  background-color: #ffffff;
  border: 1px solid #d5dee7;
  height: 40px;
}
div.org-team-list > a {
  cursor: pointer !important;
  height: 30px;
  border: none;
  margin: 10px 0 0 10px;
  display: block;
}
.org-team-list-image {
  height: 30px !important;
  width: 30px !important;
  margin-top: -5px !important;
  margin-left: 7px !important;
  margin-right: 10px;
}
.org-level2-name {
  /*text-transform: uppercase; */
  font-size: 12px;
  margin-left: 50px;
}
.org-chart .panel-body {
  border: none ! important;
  background-color: #ffffff !important;
  padding: 0 !important;
  /*    margin-right: -2px;*/
  margin-left: 15%;
  /*    width: 80%;*/
  margin-right: auto;
}
/*.org-chart .panel-heading {
    margin-left: -25px !important;
}*/
.org-chart .panel-collapse {
  padding: 0px !important;
  /*    margin-top: -32px !important;*/
  margin-top: 0 !important;
  margin-right: 0 !important;
}
.org-chart .row {
  margin-left: auto;
  margin-right: auto;
  float: none;
  padding-bottom: 20px;
  /*display: inline;*/
}
.org-chart .row div.org-manager:first-child {
  clear: left;
}
div.org-contact-details {
  margin-left: 67px;
  color: #737e84;
  font-size: 13px;
  line-height: 16px;
}
.org-menu-link {
  color: #00529f;
}
.org-subject .org-menu-link {
  color: #FFFFFF;
}
.org-team-clear {
  margin-bottom: 30px;
}
@media all and (max-width: 1199px) {
  /*    .org-report, .org-manager{
           width: 26%;
          float: left;
          margin-left: 6%;
          margin-bottom: 30px;
      }*/
}
@media all and (max-width: 767px) {
  .content {
    padding: 0 20px;
  }
  .org-team-members .org-image {
    left: auto;
    margin-top: -16px;
  }
  div.org-team-member,
  div.org-primary-manager {
    width: 87%;
  }
  .org-chart .accordion-toggle img.org-contact-hidden,
  .org-chart .accordion-toggle span.org-contact-hidden {
    right: 10%;
  }
}
/* Smartphones (portrait and landscape) ----------- */
@media only screen and (min-device-width: 320px) and (max-device-width: 480px) {
  div.org-subject {
    width: 100%;
  }
}
/* Smartphones (landscape) ----------- */
@media only screen and (min-width: 321px) {
  div.org-subject {
    width: 90%;
  }
  div.org-primary-manager {
    width: 90%;
  }
}
/* Smartphones (portrait) ----------- */
@media only screen and (max-width: 320px) {
  div.org-subject {
    width: 100%;
  }
}
/* iPads (portrait and landscape) ----------- */
@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
  div.org-subject {
    width: 40%;
  }
  .orgchart-user-image img {
    height: 80px;
    width: 80px;
  }
  .orgchart-user-details .orgchart-user-info-block {
    padding-left: 40px;
  }
  .orgchart-user-info-block .orgchart-user-heading {
    padding-left: 50px;
  }
  .orgchart-user-info-block .orgchart-user-body {
    padding-left: 50px;
  }
}
/* iPads (landscape) ----------- */
@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) and (orientation: landscape) {
  div.org-subject {
    width: 40%;
  }
  .orgchart-user-image img {
    height: 50px;
    width: 50px;
  }
  .orgchart-user-details .orgchart-user-info-block {
    padding-left: 15px;
  }
  .orgchart-user-info-block .orgchart-user-heading {
    padding-left: 40px;
  }
  .orgchart-user-info-block .orgchart-user-body {
    padding-left: 15px;
  }
}
/* iPads (portrait) ----------- */
@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) and (orientation: portrait) {
  div.org-subject {
    width: 40%;
  }
  .orgchart-user-image img {
    height: 50px;
    width: 50px;
  }
  .orgchart-user-details .orgchart-user-info-block {
    padding-left: 15px;
  }
  .orgchart-user-info-block .orgchart-user-heading {
    padding-left: 40px;
  }
  .orgchart-user-info-block .orgchart-user-body {
    padding-left: 15px;
  }
}
/* Desktops and laptops ----------- */
@media only screen and (min-width: 1224px) {
  div.org-subject {
    width: 40%;
  }
  .orgchart-user-image img {
    height: 50px;
    width: 50px;
  }
  .orgchart-user-details .orgchart-user-info-block {
    padding-left: 15px;
  }
  .orgchart-user-info-block .orgchart-user-heading {
    padding-left: 40px;
  }
  .orgchart-user-info-block .orgchart-user-body {
    padding-left: 15px;
  }
}
/* Large screens ----------- */
@media only screen and (min-width: 1824px) {
  div.org-subject {
    width: 40%;
  }
  div.org-primary-manager {
    width: 40%;
  }
  .orgchart-user-image img {
    height: 80px;
    width: 80px;
  }
  .orgchart-user-details .orgchart-user-info-block {
    padding-left: 40px;
  }
  .orgchart-user-info-block .orgchart-user-heading {
    padding-left: 50px;
  }
  .orgchart-user-info-block .orgchart-user-body {
    padding-left: 50px;
  }
}
/* iPhone 4 ----------- */
@media only screen and (-webkit-min-device-pixel-ratio: 1.5), only screen and (min-device-pixel-ratio: 1.5) {
  div.org-subject {
    width: 100%;
  }
}
.form-control-feedback {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 2;
  display: block;
  width: 34px;
  height: 34px;
  line-height: 34px;
  text-align: center;
  cursor: pointer;
}
div.row.spaced,
div.row.spaced-fieldset {
  font-size: 16px;
}
.nav-tabs ul {
  display: none;
}
.nav-tabs ul ul {
  list-style: none;
  position: absolute;
  right: 100%;
  top: -1px;
  background: #333;
}
.nav-tabs ul {
  background: #3A434E;
  border-radius: 0px;
  padding: 0;
  position: absolute;
  top: 100%;
  right: 0%;
}
.caret-left {
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
  border-right: 4px solid #FFFFFF;
  display: inline-block;
  width: 0;
  height: 0;
  margin-right: 10px;
}
.nav-tabs ul li a:hover {
  background: #000;
}
.nav-tabs ul li {
  float: none;
  border-top: solid 1px  #5f6975;
  position: relative;
}
.nav-tabs ul ul li {
  border-top: solid 1px #9da9b5;
}
.nav-tabs ul li a {
  display: block;
  cursor: pointer;
  text-decoration: none;
  padding: 10px 30px;
  clear: both;
  font-size: 13px;
  font-weight: normal;
  line-height: 1.42857143;
  white-space: nowrap;
  color: #fff;
}
.nav-tabs li:hover > ul {
  display: block;
}
.nav-tabs li:hover {
  background: #4b545f;
  background: linear-gradient(top, #4f5964 0%, #5f6975 40%);
  background: -moz-linear-gradient(top, #4f5964 0%, #5f6975 40%);
  background: -webkit-linear-gradient(top, #4f5964 0%, #5f6975 40%);
}
.nav-tabs:after {
  content: "";
  clear: both;
  display: block;
}
ul.plain-unstyled {
  padding-left: 0;
  list-style: none;
  z-index: 99999;
  font-size: 12px;
  background: #333;
}
#loading-bar .bar {
  -webkit-transition: width 350ms;
  -moz-transition: width 350ms;
  -o-transition: width 350ms;
  transition: width 350ms;
  box-shadow: 0 0 10px #ddd, 0 0 5px #ddd;
  background: #00529f;
  z-index: 2000;
  width: 100%;
  height: 8px;
}
* {
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
  border-radius: 0;
}
#tabs > ul > li:hover {
  background-color: #0E0F10;
  color: #fff;
}
#loading-bar .bar {
  -webkit-transition: width 350ms;
  -moz-transition: width 350ms;
  -o-transition: width 350ms;
  transition: width 350ms;
  box-shadow: 0 0 10px #ddd, 0 0 5px #ddd;
  background: #00529f;
  z-index: 2000;
  width: 100%;
  height: 8px;
}
.form-control {
  -webkit-border-radius: 0 !important;
  -moz-border-radius: 0 !important;
  border-radius: 0 !important;
}
.form-control:focus {
  border: 1px solid #ccc !important;
  box-shadow: none !important;
  webkit-box-shadow: none !important;
}
.width-fieldset {
  width: 50%;
  float: left;
  padding-left: 0;
  height: 34px;
}
.fieldset-spaced {
  margin-bottom: 15px;
}
.action-row {
  margin-top: 10px;
  margin-bottom: 10px;
}
.checkbox-wrapper {
  position: relative;
  height: 16px;
  width: 17px;
}
/*input[type="checkbox"] {
    opacity: 0;
    height: 16px;
    width: 17px;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 2;
}*/
/*input[type="checkbox"] + label{
    background-image: url('../images/checkbox-unchecked.jpg');
    height: 16px;
    width: 17px;
    display:inline-block;
    padding: 0 0 0 0px;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1;
}*/
/*input[type="checkbox"]:checked + label{
    background-image: url('../images/checkbox-checked.jpg');
    height: 16px;
    width: 17px;
    display:inline-block;
    padding: 0 0 0 0px;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1;
}*/
input[type="range"] {
  display: inline;
  width: 80%;
  float: none;
}
.slider-bar span.left {
  margin-right: 3%;
}
.slider-bar span.right {
  margin-left: 3%;
}
.hr-request-fieldsets label {
  width: 100%;
}
.summary-message {
  color: #00529f;
  font-weight: bold;
}
.iframe-container {
  position: relative;
  width: 100%;
  height: 0;
  overflow: hidden;
  padding-bottom: 56.25%;
  margin-bottom: 20px;
}
.videoTile iframe,
.videoDetail iframe,
.websiteTile iframe,
.websiteDetail iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
}
.htmlTile iframe {
  position: relative;
  margin-top: 10px;
  left: 0;
  width: 100%;
  height: 210px;
  border: 1px solid lightgrey;
  overflow: hidden;
}
.htmlDetail iframe {
  position: relative;
  margin-top: 10px;
  width: 100% !important;
  border: none;
  overflow: hidden;
}
.richTextTile {
  margin-top: 10px;
  height: 210px;
  overflow: auto;
}
.videoWrapper {
  position: relative;
  padding-bottom: 56.25%;
  padding-top: 25px;
  height: 0;
}
.videoWrapper video {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
.go-to-detail {
  background-color: #ddd;
  height: 25px;
  width: 100%;
  margin: 0px;
  vertical-align: middle;
  font-size: 15px;
  line-height: 1.7em;
}
.go-to-detail a {
  text-align: left;
  margin-left: 10px;
  vertical-align: middle;
  color: #76838a;
}
.go-to-detail div a {
  text-align: left;
  vertical-align: middle;
  color: white;
}
.go-to-detail div a span {
  right: 5px;
}
.go-to-detail div {
  background-color: #76838a;
  height: 25px;
  width: 30px;
  float: right;
}
.padding-left-0 {
  padding-left: 0;
}
.padding-right-0 {
  padding-right: 0;
}
.margin-left-0 {
  margin-left: 0;
}
.margin-left-1 {
  margin-left: 1px;
}
.margin-left-15 {
  margin-left: 15px;
}
.margin-right-75 {
  margin-right: 75px;
}
.margin-right-20 {
  margin-right: 20px;
}
.margin-bottom-15 {
  margin-bottom: 15px;
}
html,
body,
#outer {
  margin: 0;
  padding: 0;
  height: 100%;
  font-family: 'Noto Sans', sans-serif;
}
.details-label,
.details-value {
  color: #76838a;
  font-size: 15px;
}
.heading-color {
  color: #76838a;
}
.process-heading {
  color: #76838a;
  font-size: 16px;
}
.details-value {
  word-wrap: break-word;
}
.email-wrap {
  word-break: break-all;
}
.full-height {
  height: 100%;
  margin: 0;
  padding: 0;
}
.pdf-open {
  padding-bottom: 15px;
  margin-left: 15px;
  margin-top: 0px;
}
.pdf-close {
  padding-bottom: 15px;
  margin-left: 15px;
  margin-top: -20px;
}
.modal-margin-bottom {
  margin-bottom: 20px;
}
#client-logo img {
  margin: 10px;
  height: 60px;
}
#portaltitle {
  font-size: 27px;
  color: #838383;
  margin-top: 10px;
  margin-bottom: 10px;
  float: left;
  margin-left: 4%;
  padding: 22px;
  border-left: 1px solid lightgrey;
  padding-left: 4%;
}
#portaltitle-mobile {
  font-size: 27px;
  color: #838383;
  padding: 10px 0 20px 0;
  border-left: 0;
  border-bottom: 1px solid lightgrey;
  text-align: center;
}
.nav-indicator {
  width: 0;
  height: 0;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid #333;
  font-size: 0;
  line-height: 0;
  margin-left: 10%;
}
.nav-pills::before,
.nav-pills::after {
  width: 0;
}
.nav-pills > li {
  margin-right: -2px;
}
.nav-pills > li > a:hover {
  background-color: #aaa;
}
.nav-pills > li > a {
  background-color: #666;
  color: #fff;
}
.nav-pills > li.active > a {
  background-color: #333;
}
#nav-left-normal,
#nav-left-mobile {
  background-color: #000;
  color: #fff;
  height: 100% !important;
  padding: 0;
}
#section,
body {
  background-color: #E9EDEF;
}
#process-views {
  margin-top: 10px;
}
#process-views {
  padding-top: 10px;
}
#process-views p.list-group-item-text {
  color: #6a6b70;
}
#process-views .list-group-item-text {
  color: #78858e;
  font-size: 19px;
  font-weight: normal !important;
}
.media,
.media-body {
  overflow: visible;
}
#process-views .h3 {
  color: #686b74;
}
#process-views td {
  color: #748388;
}
#process-views span.view-details-btn-plus {
  color: #77848a;
}
#process-views h4 {
  color: #74818a;
}
#process-views .panel-body p,
#process-views .other-properties {
  color: #78858e;
}
#process-views .no-objectives {
  padding-bottom: 15px;
  padding-left: 15px;
  color: #768389;
}
#process-views .btn {
  line-height: 1.2;
  padding: 4px 16px;
}
#process-views .progress-bar {
  background-color: #00529f;
}
#process-views .progress-development {
  background-color: orangered;
}
#process-views .progress-current {
  background-color: green;
}
#process-views .progress-required {
  background-color: red;
}
#sub-section .panel .row {
  margin-top: 10px;
  margin-bottom: 10px;
}
#sub-section .panel {
  background-color: transparent;
  border: none !important;
  webkit-box-shadow: none;
  box-shadow: none;
}
#cat-menu-icon {
  width: 40px;
  height: 40px;
  position: absolute;
  top: 12px;
  padding: 10px 0 0 11px;
  border: 1px solid #d3d3d3;
  border-radius: 3px;
  -webkit-border-radius: 3px;
  -moz-border-radius: 3px;
  float: left;
}
.subitem,
.indent-2 {
  padding-left: 50px;
}
.indent-1 {
  padding-left: 25px;
}
.panel-empty {
  margin-top: 20px;
}
.nav-group-header,
.nav-menu-header-mobile,
.nav-menu-header-normal {
  padding: 10px 10px;
  font-size: 15px;
}
#nav-left-mobile .nav-menu-header-mobile {
  background-color: #0e0f10;
  margin-top: -10px;
}
.org-menu-header-mobile {
  padding: 10px 10px;
  font-size: 15px;
  margin-top: -10px;
  color: #ffffff;
  background-color: #005aae;
}
#context_div {
  background: #fff;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
  text-align: left;
  line-height: 60px;
  height: 65px;
}
#mobile_categories {
  background-color: #3A434E;
  height: 43px;
}
/* override jquery mmenu styles */
.mm-menu > .mm-panel {
  padding: 10px 0;
}
/* END jquery mmenu styles */
#footer {
  background-color: #E9EDEF;
  padding-top: 10px;
  padding-right: 7px;
  padding-bottom: 20px;
  padding-left: 7px;
  border-top: solid 1px #C4C4C4;
  margin-top: 25px;
  font-weight: normal;
}
#footer .separator {
  margin: 30px -7px 10px -7px;
  border-top: solid 1px #C4C4C4;
}
#footer .logoutBtn {
  border-right-color: #C4C4C4;
}
#footer label {
  font-weight: normal;
  font-size: 12px;
  color: #333333;
}
.powered-by-div {
  float: right;
  color: #808080;
  font-size: 0.6em;
}
.powered-by-img {
  float: left;
  height: 50px;
  width: 53px;
  padding-left: 3%;
}
.powered-by-text {
  float: left;
  padding-top: 23px;
}
.nav > li > a.moreLink {
  background-color: #292929;
}
/* New CSS for nav bar categories */
.nav-tabs {
  background-color: #3A434E;
  border-bottom: 1px solid #3A434E;
}
.nav-tabs.empty-menu {
  line-height: 1.42857143;
}
.nav-tabs > li {
  position: relative;
  display: block;
  border-right: solid 1px #4D555C;
}
.nav-tabs > li:first-child {
  margin-left: 20px;
}
.nav-tabs > li > a {
  margin-right: 0px;
  line-height: 1.42857143;
  background-color: #3A434E;
  color: #FCFEFF;
  border-radius: 0;
  border: 0;
}
.nav > li > a {
  position: relative;
  display: block;
  padding: 18px 30px;
}
.nav > li > a:hover,
.nav > li > a:focus {
  text-decoration: none;
  background-color: #0E0F10;
}
.nav .open > a,
.nav .open > a:hover,
.nav .open > a:focus {
  background-color: #0E0F10;
  border: none;
}
.nav-tabs .dropdown-menu-desktop {
  margin-top: 0px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.nav-tabs .dropdown-menu {
  margin-top: 0px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.navbar-brand {
  float: left;
  height: 47px;
  padding: 12px 12px;
  font-size: 18px;
  line-height: 20px;
}
a.navbar-brand {
  color: #fff;
}
.nav-tabs > li > a.dropdown-toggle {
  background-color: #282829;
  padding: 11px 17px;
}
.nav-tabs > li.dropdown {
  border-right: none;
}
.pull-right > .dropdown-menu-desktop {
  right: 7px;
  left: auto;
}
.dropdown-menu-desktop {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 1000;
  display: none;
  float: left;
  min-width: 160px;
  padding: 5px 0;
  margin: 2px 0 0;
  font-size: 14px;
  list-style: none;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ccc;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-radius: 4px;
  -webkit-box-shadow: 0 6px 12px rgba(0, 0, 0, 0.175);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.175);
}
.dropdown-menu-desktop > li {
  display: block;
}
.dropdown-menu > li {
  display: block;
}
.nav-tabs > li.active > a,
.nav-tabs > li.active > a:hover,
.nav-tabs > li.active > a:focus {
  color: #fff;
  cursor: default;
  background-color: #0E0F10;
  border-bottom-color: transparent;
  border: 0;
}
.nav-tabs > li > a:hover {
  background-color: #0E0F10;
}
.dropdown-menu-desktop {
  border-radius: 0px;
  border: 0;
  -webkit-box-shadow: none;
  box-shadow: none;
  background-color: #0E0F10;
  min-width: 210px;
  padding: 0px 0;
  margin: 2px 0 0;
}
.dropdown-menu-desktop > li > a {
  color: #ddd;
  display: block;
  cursor: pointer;
  text-decoration: none;
  padding: 10px 20px;
  clear: both;
  font-weight: normal;
  line-height: 1.42857143;
  white-space: nowrap;
  border-bottom: solid 1px #383E44;
}
.dropdown-menu-desktop > li > a:hover,
.dropdown-menu-desktop > li > a:focus {
  color: #fff;
  text-decoration: none;
  background-color: #5F5F5F;
}
.dropdown-menu {
  border-radius: 0px;
  border: 0;
  -webkit-box-shadow: none;
  box-shadow: none;
  background-color: #0E0F10;
  min-width: 210px;
  padding: 0px 0;
  margin: 2px 0 0;
}
.dropdown-menu > li > a {
  color: #ddd;
  display: block;
  cursor: pointer;
  text-decoration: none;
  padding: 10px 20px;
  clear: both;
  font-weight: normal;
  line-height: 1.42857143;
  white-space: nowrap;
  border-bottom: solid 1px #383E44;
}
.dropdown-menu > li > a:hover,
.dropdown-menu > li > a:focus {
  color: #fff;
  text-decoration: none;
  background-color: #5F5F5F;
}
.bottomPadding {
  padding-bottom: 15px !important;
}
.pickadate-header {
  position: relative;
}
.pager li > a,
.pager li > span {
  display: inline-block;
  cursor: pointer;
  padding: 5px 14px;
  border-radius: 0px;
  background-color: #FFFFFF;
  color: #00529f;
  border: 2px solid #00529f;
}
.pager li > a:hover {
  background-color: #00529f;
  color: #FFFFFF;
}
.absence-container {
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 0px;
  padding-left: 15px;
  background-color: #fff;
  border-top: solid 5px #003d76;
  border-bottom: solid 5px #ddd;
}
.changes {
  background-color: #fafafa !important;
  transition: .8s;
  cursor: pointer;
  display: block;
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 5px;
  padding-left: 15px;
  border-bottom: solid 1px #ddd;
}
.spacer20-mobile {
  margin-right: 15px;
  margin-left: 15px;
}
.h3-borders-changes-mobile {
  margin-top: 0px;
  padding-bottom: 10px;
  border-bottom: solid 1px #ddd;
  font-size: large;
  margin-bottom: 0px !important;
}
/*#sub-section .panel > .panel-collapse .panel-body h5 {
    padding-bottom: 0px;
    margin: 10px 0 10px;
    color: #309FE1;
    font-size: 15px;
    font-weight: 500;
}*/
.changes:hover {
  background-color: #efefef !important;
}
.hrRequestSpacer {
  margin-bottom: 23px !important;
  border-bottom-color: #EAEAEA;
  border-bottom-style: solid;
  border-bottom-width: 5px;
}
h5.hrRequestHeader {
  padding-bottom: 0px;
  margin: 10px 0 10px;
  color: #00529f;
  font-size: 15px;
  font-weight: 500;
}
.h3-borders-changes {
  margin-top: 0px;
  padding-bottom: 10px;
  border-bottom: solid 1px #ddd;
  font-size: large;
}
.pager {
  padding-left: 0;
  margin-top: 0px;
  margin-right: 15px;
  margin-bottom: 0px;
  margin-left: 15px;
  text-align: center;
  list-style: none;
}
.pickadate-main {
  margin: 0;
  padding: 0;
  width: 100%;
  text-align: center;
  font-size: 12px;
}
.pickadate a:visited,
.pickadate a {
  color: #666666;
}
.pickadate-cell {
  overflow: hidden;
  margin: 0;
  padding: 0;
}
.float-left li {
  width: 2.285% !important;
  padding: 0.3% 0 0.3% 0 !important;
}
.procedure-details {
  max-height: 100px;
  transition: .8s;
  overflow: hidden;
}
.media-calendar-body {
  text-align: left !important;
  font-size: 10px;
}
.media-calendar-body h4 {
  text-align: left !important;
  font-size: 12px;
  font-weight: normal;
  margin-bottom: 1px;
  color: #00529f !important;
}
.td-calendar {
  width: 150px !important;
  background-color: #F4F4F4 !important;
  transition: .8s;
}
.td-calendar:hover {
  background-color: #fefefe !important;
}
.callout-borders {
  margin-bottom: 9px;
  padding-bottom: 10px;
  margin-top: 0px;
  padding-left: 10px;
  padding-right: 5px;
  padding-top: 5px;
  background-color: #fff;
  color: #454545;
  font-size: 13px;
}
.callout-label {
  display: inline;
  padding: .2em .6em .3em;
  font-size: 10px;
  text-transform: uppercase;
  font-weight: normal;
  line-height: 21px;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0px !important;
}
.callout {
  margin: 8px 0;
  padding: 10px 10px 1px 10px;
  border: none;
  /*border-left: 4px solid transparent;*/
  position: relative;
}
.callout-content {
  padding-bottom: 0px;
  padding-top: 0px;
}
.callout h4 {
  position: absolute;
  z-index: 4;
  left: 0;
  top: 0;
  background: #415964;
  padding: .6em 10px .6em 10px;
  -webkit-border-radius: 0 0 13px 0;
  border-radius: 0 0 0px 0;
  margin: 0;
  color: #FFF !important;
  font-size: .8em;
  font-weight: bold;
  text-transform: uppercase;
  display: none;
}
.callout .callout-link {
  font-weight: bold;
}
.callout > p,
.callout > ul {
  margin-bottom: 0;
}
.callout > p + p {
  margin-top: 5px;
}
.callout-success {
  background-color: #D5DADE;
}
.callout-success hr {
  border-top-color: #c9e2b3;
}
.callout-success .callout-link {
  color: #356635;
}
.callout-info {
  background-color: #E2EAF1;
  border-color: #d0e3f0;
}
.callout-info hr {
  border-top-color: #a6e1ec;
}
.callout-info .callout-link {
  color: #2d6987;
}
.callout-warning {
  background-color: #fefbed;
  border-color: #f1e7bc;
}
.callout-warning hr {
  border-top-color: #f8e5be;
}
.callout-warning .callout-link {
  color: #a47e3c;
}
.callout-danger {
  background-color: #fcf2f2;
  border-color: #dFb5b4;
}
.callout-danger hr {
  border-top-color: #e6c1c7;
}
.callout-danger .callout-link {
  color: #953b39;
}
.pickadate-cell li.hidden {
  max-height: 0;
}
.callout-success h4 {
  background-color: #DC522A !important;
}
.pickadate-cell li {
  display: block;
  float: left;
  border: 1px solid #DCDCDC;
  border-width: 0 1px 1px 0;
  width: 14.285%;
  padding: 1.3% 0 1.3% 0;
  box-sizing: border-box;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
  max-height: 100px;
  transition: .8s;
  overflow: hidden;
}
.pickadate-cell li:nth-child(7n+0) {
  border-right: 1px solid #DCDCDC;
}
.pickadate-cell li:nth-child(1),
.pickadate-cell li:nth-child(8),
.pickadate-cell li:nth-child(15),
.pickadate-cell li:nth-child(22),
.pickadate-cell li:nth-child(29),
.pickadate-cell li:nth-child(36) {
  border-left: 1px solid #DCDCDC;
}
.pickadate-cell .pickadate-disabled,
.pickadate-cell .pickadate-disabled a {
  color: #DCDCDC;
}
.pickadate-cell .pickadate-enabled,
table.calendar-table td.pickadate-enabled {
  cursor: pointer !important;
  font-size: 12px;
  color: #666666;
}
.animate-enter,
.animate-leave {
  -webkit-transition: 400ms cubic-bezier(0.25, 0.25, 0.75, 0.75) all;
  -moz-transition: 400ms cubic-bezier(0.25, 0.25, 0.75, 0.75) all;
  -ms-transition: 400ms cubic-bezier(0.25, 0.25, 0.75, 0.75) all;
  -o-transition: 400ms cubic-bezier(0.25, 0.25, 0.75, 0.75) all;
  transition: 400ms cubic-bezier(0.25, 0.25, 0.75, 0.75) all;
  position: relative;
  display: block;
}
.animate-enter.animate-enter-active,
.animate-leave {
  opacity: 1;
  top: 0;
  height: 30px;
}
.animate-leave.animate-leave-active,
.animate-enter {
  opacity: 0;
  top: -50px;
  height: 0px;
}
.pickadate-cell .pickadate-today {
  background-color: #eaeaea;
}
.pickadate-cell .pickadate-head,
td.pickadate-head {
  border-top: 1px solid #DCDCDC;
  background: #f3f3f3;
}
.pickadate-cell .pickadate-head:nth-child(1),
.pickadate-cell .pickadate-head:nth-child(7) {
  background: #f3f3f3;
}
.pickadate-centered-heading {
  font-weight: normal;
  text-align: center;
  font-size: 1em;
  margin: 13px 0 13px 0;
}
.pickadate-controls {
  position: absolute;
  z-index: 10;
  width: 100%;
}
.pickadate-cell .pickadate-enabled:hover {
  background-color: #e4e7ec;
  color: #666666;
}
.pickadate-controls .pickadate-next {
  float: right;
}
.pickadate-controls a {
  text-decoration: none;
  font-size: 0.9em;
}
.pickadate-controls a:hover {
  text-decoration: none;
  color: #00529f;
}
.calendar-container {
  width: 300px;
  float: left;
  margin-right: 10px;
}
button.org-chart-btn {
  background-color: #FFFFFF;
  color: #00529f;
  padding-top: 7px;
  padding-right: 10px;
  padding-bottom: 7px;
  padding-left: 6px;
  border: 1px solid #00529f;
  text-decoration: none;
  font-weight: normal;
  font-size: 13px;
  line-height: 0.5;
  margin-top: 7px;
  background-color: #F4F4F4;
  text-transform: uppercase;
  border-color: #ddd;
}
img.org-chart-icon {
  opacity: 0.4;
  width: 13px;
  height: 13px;
  margin-right: 3px;
  filter: alpha(opacity=40);
  /* For IE8 and earlier */
}
.click-to-show {
  background-color: #7C858F !important;
}
img.calendar-img {
  height: 27px;
  width: 27px;
  margin-top: 0px;
  margin-left: 3px;
  padding-bottom: 2px;
  cursor: pointer;
}
table.calendar-table td {
  width: 30px;
  display: table-cell;
  vertical-align: top;
  padding-top: 6px !important;
  padding-right: 1px !important;
  padding-bottom: 1px !important;
  padding-left: 1px !important;
  height: 30px;
}
table.calendar-table td div {
  height: 100%;
}
.selected-date {
  padding: 10px;
  text-align: center;
}
.legend-button-container {
  text-align: center;
  margin-top: 2px !important;
}
.legend-button {
  background-color: #ddd;
  font-size: 11px;
  padding-top: 0px;
  padding-right: 10px;
  padding-bottom: 3px;
  padding-left: 10px;
  cursor: pointer;
  text-decoration: none !important;
}
.legend-button:hover {
  color: #878787;
}
.legend-bg-container {
  padding-top: 0px;
  padding-right: 15px;
  padding-bottom: 0px;
  padding-left: 15px;
  margin-top: -10px;
  /* background-color: #fff; */
  /* border-top: solid 5px @defaultThemeSectionLabelBorder; */
  /* border-bottom: solid 5px #ddd; */
}
.legend-bg {
  margin-top: -25px !important;
  margin-bottom: 20px !important;
  background-color: #fbfbfb;
  padding-top: 20px !important;
  display: none;
  /*transition: .8s;*/
}
.legend-bg:hover {
  background-color: #fefefe;
}
.legend-title {
  margin-top: 0;
  margin-bottom: 0;
  font-size: 10.5px;
  color: inherit;
  font-weight: normal;
  text-transform: uppercase;
}
.pickadate-cell .pickadate-vacation,
td.pickadate-vacation {
  background-color: #474747;
  color: white !important;
}
.pickadate-cell .pickadate-dayoff,
td.pickadate-dayoff {
  background-color: #5FC27B;
  color: white !important;
}
.pickadate-cell .pickadate-dayoff:hover,
td.pickadate-dayoff:hover {
  background-color: #3B6F4A !important;
  color: white !important;
}
li.pickadate-enabled.pickadate-dayoff.pending,
td.pickadate-dayoff.pending,
.legend-pending-vacations {
  background-color: #fff !important;
  box-shadow: inset 0 0 0 3px #5FC27B !important;
  color: #5FC27B !important;
  border-radius: 0px;
}
li.pickadate-enabled.pickadate-dayoff.pending:hover,
td.pickadate-dayoff.pending:hover {
  background-color: #3B6F4A !important;
  color: white !important;
}
li.pickadate-enabled.pickadate-dayoff.provisional,
td.pickadate-dayoff.provisional,
.legend-provisional-vacations {
  background-color: #99D3AA !important;
  box-shadow: inset 0 0 0 5px #5FC27B !important;
  color: #FDFDFD !important;
  border-radius: 0px;
}
li.pickadate-enabled.pickadate-dayoff.provisional:hover,
td.pickadate-dayoff.provisional:hover,
.legend-approved-vacations {
  background-color: #3B6F4A !important;
  color: white !important;
  border-radius: 0px;
}
.pickadate-cell .pickadate-holiday,
td.pickadate-holiday {
  background-color: #55ADDF;
  color: white !important;
}
.pickadate-cell .pickadate-holiday:hover,
td.pickadate-holiday:hover,
.legend-approved-absences {
  background-color: #2B4663 !important;
  color: white !important;
  border-radius: 0px;
}
li.pickadate-enabled.pickadate-holiday.pending,
td.pickadate-holiday.pending,
.legend-pending-absences {
  background-color: #fff !important;
  box-shadow: inset 0 0 0 3px #55ADDF !important;
  color: #55ADDF !important;
  border-radius: 0px;
}
li.pickadate-enabled.pickadate-holiday.pending:hover,
td.pickadate-holiday.pending:hover {
  background-color: #2B4663 !important;
  color: white !important;
}
li.pickadate-enabled.pickadate-holiday.provisional,
td.pickadate-holiday.provisional,
.legend-provisional-absences {
  background-color: #91CAEB !important;
  box-shadow: inset 0 0 0 4px #55ADDF !important;
  color: #F8FAFC !important;
  border-radius: 0px;
}
li.pickadate-enabled.pickadate-holiday.provisional:hover,
td.pickadate-holiday.provisional:hover {
  background-color: #2B4663 !important;
  color: white !important;
}
.pickadate-cell .pickadate-coyholiday,
td.pickadate-coyholiday {
  background-color: #FCB05F;
  color: white !important;
}
.pickadate-cell .pickadate-coyholiday:hover,
td.pickadate-coyholiday:hover {
  background-color: #f56a2e !important;
  color: white !important;
}
.pickadate-cell .pickadate-weekend,
td.pickadate-weekend {
  background-color: #CBCBCB !important;
  color: #848484 !important;
}
.loadingBarSpacer {
  margin-bottom: 30px;
  height: 11px !important;
  /*background-color: #D9E2E7;*/
}
.progress.active .progress-bar {
  -webkit-animation: progress-bar-stripes 0.4s linear infinite;
  animation: progress-bar-stripes 0.4s linear infinite;
}
.btn {
  display: inline-block;
  padding: 6px 12px;
  margin-bottom: 0;
  font-size: 14px;
  font-weight: normal;
  line-height: 1.42857143;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  background-image: none;
  border: 1px solid transparent;
  border-radius: 0px !IMPORTANT;
}
.confirm-action-btn {
  padding-top: 20px;
  padding-right: 10px;
  padding-bottom: 20px;
  padding-left: 10px;
}
.confirm-box-borders {
  border: solid 10px #575757;
  background-color: #fff;
}
.confirm-action-btn .btn {
  margin-right: 0px;
  margin-left: 5px;
}
.confirm-action-btn .modal-cancel {
  border: solid 1px #ddd;
}
.btn-sm,
.btn-group-sm > .btn {
  padding: 5px 10px;
  font-size: 12px;
  line-height: 1.35;
}
.btn-sm:focus,
.btn-group-sm > .btn:focus,
.btn-sm:active,
.btn-group-sm > .btn:active,
.btn-sm:hover,
.btn-group-sm > .btn:hover {
  border: 1px solid white !important;
}
.btn-left-border {
  border-left: solid 1px #adadad !important;
}
.teamProfileText {
  text-transform: uppercase;
  font-size: 11px;
}
.teamProfileImg {
  padding: 0;
  background-color: #fff;
  display: inline;
  -webkit-border-radius: 50%;
  -moz-border-radius: 50%;
  border-radius: 50%;
  -html-border-radius: 50%;
  border: 6px solid #fff;
  width: 100%;
}
.teamProfileImg img {
  -webkit-border-radius: 50%;
  -moz-border-radius: 50%;
  border-radius: 50%;
  vertical-align: middle;
  width: 80px;
  height: 80px;
  margin: 0px;
}
.teamProfileDetailsMobile {
  display: none;
}
.navbar {
  position: relative;
  min-height: 50px;
  margin-bottom: 20px;
  border: none;
}
.h3 {
  margin-bottom: 0px;
}
.smaller-icon {
  top: -1px;
  font-size: 7px;
}
.btn-group > .btn + .dropdown-toggle {
  padding-right: 13px;
  padding-left: 13px;
}
.label {
  display: inline;
  padding-top: 8px;
  padding-right: 13px;
  padding-bottom: 8px;
  padding-left: 13px;
  font-size: 14px;
  text-transform: uppercase;
  font-weight: normal;
  line-height: 35px;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0px !important;
}
a.accordion-toggle:hover {
  text-decoration: none !important;
}
.label-table {
  background-color: #3A434E;
  font-size: 13px;
  border-bottom: 2px solid #272626;
  border-left: 2px solid #272626;
  border-right: 2px solid #272626;
  margin-left: 1px;
}
.label-table-div {
  margin-bottom: -10px;
}
.currency .label {
  line-height: 20px;
}
.remove-all-margin {
  margin-top: 15px;
  margin-left: -15px;
  margin-right: -15px;
  padding-bottom: 5px;
}
#tabs > ul {
  padding: 0;
  margin: 0;
  list-style-type: none;
  text-align: justify;
}
#tabs > ul::after {
  content: " ";
  display: table;
  clear: both;
}
#tabs > ul > li {
  border-right: solid 1px #4D555C;
  background-color: #3A434E;
  padding-top: 12px;
  padding-right: 13px;
  padding-bottom: 12px;
  padding-left: 13px;
  font-size: 11px;
  text-align: center;
  text-transform: uppercase;
  font-weight: normal;
  color: #fff;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0px !important;
  cursor: pointer;
  display: table-cell;
  width: 1%;
}
#tabs > ul > li:last-child {
  border-right: none;
}
li.long-label {
  font-size: 13px !important;
  padding-bottom: 7px !important;
  white-space: normal !important;
}
.btn-primary {
  color: #fff;
  background-color: #00529f;
  border-color: transparent;
}
.team-accordion-mobile .other-properties .col-test1 {
  border: none !important;
  padding-right: 5px;
  padding-left: 5px;
  margin-right: 0px;
  margin-left: 0px;
}
.team-accordion-mobile .other-properties .col-test2 {
  border: none !important;
  padding-right: 5px;
  padding-left: 5px;
  margin-right: 0px;
  margin-left: 0px;
}
.team-vertical-spacer {
  margin-bottom: 20px;
  margin-top: 30px;
  border-bottom: solid 5px #ddd;
  background-color: #fff;
}
#mainView {
  clear: both;
  padding-top: 15px;
  padding-right: 0px;
  padding-bottom: 10px;
  padding-left: 0px;
  background-color: #FFF;
  border-top: solid 5px #003d76;
  margin-top: 0px;
  margin-left: -15px;
  margin-right: -15px;
}
#mainViewTeam {
  clear: both;
  padding-top: 15px;
  padding-right: 0px;
  padding-bottom: 10px;
  padding-left: 0px;
  background-color: #FFF;
  border-top: solid 5px #003d76;
  margin-top: 0px;
  margin-left: -15px;
  margin-right: -15px;
}
.mainView {
  clear: both;
  padding-top: 15px;
  padding-right: 0px;
  padding-bottom: 10px;
  padding-left: 0px;
  background-color: #FFF;
  border-top: solid 5px #003d76;
  margin-top: 0px;
  margin-left: -15px;
  margin-right: -15px;
}
.mainView.list-no-accordion {
  background-color: #E9EDEF;
}
.mainViewTeam {
  clear: both;
  padding-top: 15px;
  padding-right: 0px;
  padding-bottom: 10px;
  padding-left: 0px;
  background-color: #FFF;
  border-top: solid 5px #003d76;
  margin-top: 0px;
  margin-left: -15px;
  margin-right: -15px;
}
#tabs {
  padding-top: 18px;
  margin-left: -15px;
  margin-right: -15px;
  padding-left: 15px;
  padding-right: 15px;
  margin-top: 0px;
}
#tabs > ul > li.active {
  background-color: #00529f;
  color: #fff;
}
.tabs {
  padding-top: 18px;
  margin-left: -15px;
  margin-right: -15px;
  padding-left: 15px;
  padding-right: 15px;
  margin-top: 0px;
}
.tabs > ul > li.active {
  background-color: #00529f;
  color: #fff;
}
.panel-default > .panel-heading {
  color: #333;
  background-color: #FFFFFF;
  border-color: #FFF;
}
.other-milestones {
  padding-top: 0px;
  padding-right: 20px;
  padding-bottom: 20px;
  padding-left: 20px;
  margin-top: 0px !important;
}
.newMilestoneMobileTxt {
  line-height: 1;
  color: #330;
  font-weight: bold;
  text-transform: uppercase;
  padding-top: 10px;
}
.milestoneMobileTxt {
  line-height: 1;
  color: #330;
  font-weight: bold;
  padding-top: 10px;
  padding-bottom: 10px;
}
.progress {
  height: 20px;
  margin-bottom: 0px;
  overflow: hidden;
  background-color: #E5F8FC;
  border-radius: 0;
  -webkit-box-shadow: none;
  box-shadow: none;
}
.progress-skills {
  height: 10px;
  margin-bottom: 5px;
  overflow: hidden;
  background-color: #E9EDEF;
  border-radius: 0;
  -webkit-box-shadow: none;
  box-shadow: none;
}
.progress-objectives-tile {
  height: 40px;
  margin-top: 5px;
  font-size: 1em;
  margin-bottom: 10px;
}
td.progress-bar {
  margin-top: 5px;
  padding-top: 15px !important;
}
.row.table-row > [class*="col-"].custom {
  text-align: left;
  width: 100%;
}
.position-btn {
  position: absolute;
  bottom: 5px;
  right: 0;
  margin-right: 10px;
}
#sub-section .team-accordion .objectives-container:last-child {
  padding-bottom: 0px;
  margin-bottom: 15px !important;
  padding-left: 15px;
  background-color: #fff;
  border-top: solid 5px #003d76;
}
#sub-section .team-accordion .objectives-container {
  border-left: solid 1px #ddd;
  border-right: solid 1px #ddd;
}
#sub-section .team-accordion .panel > .panel-collapse {
  padding-left: 15px;
  padding-right: 15px;
  margin-top: -12px;
  margin-right: 0px;
  margin-bottom: 12px !important;
}
.btn-group + .btn-group {
  margin-left: 0px;
}
#sub-section .team-accordion .panel > .teamProfileImg img {
  width: 75px;
  height: 75px;
}
#sub-section .team-accordion .panel > .panel-heading {
  padding: 0px 15px;
  border-bottom: 1px solid transparent;
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
  cursor: pointer;
}
#sub-section .team-accordion .panel > .panel-collapse .panel-body h4.panel-title {
  line-height: 0.8;
  font-size: 13px;
  margin-bottom: 0px;
  padding-bottom: 0px;
  border-bottom: none !important;
}
#sub-section .team-accordion .panel > .panel-collapse .panel-body h4 {
  padding-bottom: 10px;
  /*    margin: 0px 0 0px;*/
  border-bottom: 1px solid #eee;
}
#sub-section .team-accordion .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
  line-height: 0.8;
  font-size: 13px;
  border-bottom: none !important;
}
.team-members-mobile {
  background-color: #3A434E;
  height: 43px;
}
.team-accordion-remove-margin {
  margin-right: 0px !important;
  margin-left: 0px !important;
  margin-bottom: 0px !important;
}
.team-accordion-border {
  border: 1px solid #ddd;
  padding: 15px;
  color: #78858e;
  font-size: 19px;
  font-weight: normal !important;
}
#sub-section .panel > .panel-collapse {
  padding-left: 15px;
  padding-right: 15px;
  margin-top: -21px;
  margin-right: 1px;
  /*    margin-bottom: 12px !important;*/
}
#sub-section .panel > .panel-heading :hover {
  text-decoration: none !important;
}
#sub-section .panel > .panel-collapse .panel-body h4 {
  padding-bottom: 0px;
  margin: 25px 0 10px;
}
#sub-section .panel > .panel-collapse .panel-body .col-lg-6 p {
  margin: 10px 0 20px 0;
  white-space: pre-wrap;
  /* css-3 */
  word-wrap: break-word;
  /* Internet Explorer 5.5+ */
  word-break: break-all;
  white-space: normal;
}
#sub-section .panel > .panel-collapse .panel-body p {
  margin: 3px 0 3px 0;
  white-space: pre-wrap;
  /* css-3 */
  word-wrap: break-word;
  /* Internet Explorer 5.5+ */
  word-break: break-all;
  white-space: normal;
}
.objectives-table {
  margin-bottom: 0px !important;
}
.objectives-table-borders {
  border-left: 1px solid #ddd;
  border-right: 1px solid #ddd;
  margin-bottom: 0px !important;
}
.absences-balances-table {
  border-left: 1px solid #ddd;
  border-right: 1px solid #ddd;
  border-bottom: 1px solid #ddd;
}
.absences-team-balances-table {
  margin-top: 15px;
  margin-bottom: 15px;
}
.clear-padding {
  padding-left: 0 !important;
  padding-right: 0 !important;
}
.clear-margin {
  margin-left: 0!important;
  margin-right: 0!important;
}
.view-details-row {
  margin-top: 0px !important;
}
div.view-details-row-mobile {
  background-color: #E9EDEF;
  margin-left: 0px;
  margin-right: 0px;
  margin-top: 0px !important;
  margin-bottom: 0px !important;
  padding-top: 20px;
  padding-right: 20px;
  padding-bottom: 5px;
  padding-left: 22px;
  border-bottom: solid 5px #ddd;
  border-right: solid 1px #ddd;
  border-left: solid 1px #ddd;
}
div.view-details-row-mobile-open {
  background-color: #E9EDEF;
  margin-left: 0px;
  margin-right: 0px;
  margin-top: 0px !important;
  margin-bottom: 0px !important;
  padding-top: 20px;
  padding-right: 20px;
  padding-bottom: 5px;
  padding-left: 22px;
  border-bottom: solid 1px #ddd;
  border-right: solid 1px #ddd;
  border-left: solid 1px #ddd;
}
div.view-details-row-mobile .col-xs-6 {
  padding: 0;
}
div.view-details-row-mobile-open .col-xs-6 {
  padding: 0;
}
.other-properties {
  padding: 20px;
  margin-top: 0px !important;
  margin-bottom: 0px !important;
  background-color: #FFFFFF;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  border-bottom-color: #dddddd;
  border-bottom-style: solid;
  border-bottom-width: 1px;
}
.view-details-btn-open {
  vertical-align: bottom;
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 13px;
  padding-left: 15px;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 2px;
  border-top-color: #dddddd;
  border-top-style: solid;
  border-top-width: 2px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 2px;
  cursor: pointer;
  background-color: #fff;
  margin-bottom: -5px;
  margin-left: -5px;
}
.view-details-btn-close {
  vertical-align: bottom;
  padding-top: 9px;
  padding-right: 15px;
  padding-bottom: 8px;
  padding-left: 15px;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 2px;
  border-top-color: #dddddd;
  border-top-style: solid;
  border-top-width: 2px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 2px;
  border-bottom: 2px solid #dddddd;
  cursor: pointer;
  background-color: #fff;
  margin-bottom: -5px;
  margin-left: -5px;
}
.view-accrual-btn-open {
  vertical-align: bottom;
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 10px;
  padding-left: 15px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 2px;
  cursor: pointer;
  background-color: #00529f;
  margin-bottom: 0px;
  margin-left: -5px;
}
.view-accrual-btn-close {
  vertical-align: bottom;
  padding-top: 17px;
  padding-right: 15px;
  padding-bottom: 15px;
  padding-left: 15px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 2px;
  cursor: pointer;
  background-color: #00529f;
  margin-bottom: 1px;
  margin-left: -5px;
}
.h3-borders {
  margin-top: 0px;
  padding-bottom: 10px;
}
.h3-table {
  margin-top: 20px;
  margin-bottom: 10px;
}
.panel-body {
  padding: 0;
}
.objectives-panel-body {
  padding-top: 0px;
  padding-right: 0px;
  padding-bottom: 15px;
  padding-left: 0px;
}
.objectives-panel-body > h3 {
  margin-top: 10px;
}
.view-details-section {
  padding-top: 20px;
  padding-right: 20px;
  padding-bottom: 5px;
  padding-left: 22px;
  margin-right: 1px;
  border-top-color: #dddddd;
  border-top-style: solid;
  border-top-width: 1px;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  border-bottom-color: #dddddd;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  background-color: #E9EDEF;
}
.button,
button.btn-no {
  background-color: #FFFFFF;
  color: #00529f;
  padding: 5px 20px 5px 20px;
  border: 2px solid #00529f;
  text-decoration: none;
  font-weight: bold;
}
button.btn-no {
  padding: 1px 6px;
}
.title-in-detail {
  margin-top: -50px;
}
a.button {
  color: #00529f;
}
.table-responsive {
  margin-bottom: 0px !important;
}
a.myempty-class span.active {
  display: normal !important;
}
a.myempty-class span.inactive {
  display: none;
}
.view-details-section-open {
  padding-top: 20px;
  padding-right: 20px;
  padding-bottom: 5px;
  padding-left: 22px;
  margin-right: 0px;
  border-top-color: #dddddd;
  border-top-style: solid;
  border-top-width: 1px;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  background-color: #E9EDEF;
}
.view-details-btn-plus {
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 2px;
  border-top-color: #dddddd;
  border-top-style: solid;
  border-top-width: 2px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 2px;
  border-bottom-color: #dddddd;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  line-height: 1.33;
  background-color: #fff;
  padding-top: 6px;
  padding-right: 15px;
  padding-bottom: 4px;
  padding-left: 15px;
  color: #333;
  font-weight: normal;
  text-align: center;
  font-size: 13px;
  white-space: nowrap;
  vertical-align: bottom;
  cursor: pointer;
  height: 29px !important;
  width: 115px !important;
}
div.accordian-spacer {
  margin-bottom: 15px !important;
  border: none !important;
  webkit-box-shadow: none;
  box-shadow: none;
}
.table > thead > tr > th {
  vertical-align: bottom;
  border-bottom: 2px solid #ddd;
  background-color: #3A434E;
  color: #fff;
  text-transform: uppercase;
  font-size: 13px;
  border-right: solid 1px #4D555C;
}
.absences-team-balances-table .table > thead > tr > th {
  font-size: 12px;
}
.table > thead > tr > th,
.table > tbody > tr > th,
.table > tfoot > tr > th,
.table > thead > tr > td,
.table > tbody > tr > td,
.table > tfoot > tr > td {
  padding: 4px;
  line-height: 1.42857143;
  vertical-align: top;
  font-weight: normal;
  border-top: 1px solid #ddd;
}
.objectives-sub-table > tbody > tr > td {
  border-bottom: 1px solid #ddd !important;
}
.action-btn {
  margin-top: 0px;
  margin-bottom: 0px;
  color: #333;
  background-color: #fff;
  border-color: #ccc;
  margin-left: 10px;
  margin-right: 1px;
}
.label-primary {
  background-color: #00529f;
}
div.accordian-spacer:last-of-type {
  margin-bottom: 0px;
}
div.bordered {
  border-bottom: solid 1px #ddd;
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 15px;
  padding-left: 0px;
  margin-top: 0px !important;
  margin-bottom: 0px !important;
}
div.bordered:first-child {
  padding-top: 0px;
}
div.spaced,
div.spaced-fieldset {
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 15px;
  padding-left: 0px;
  margin-top: 0px !important;
  margin-bottom: 0px !important;
}
div.spaced:first-child {
  padding-top: 0px;
}
div.spaced-action {
  margin-top: 10px;
  margin-bottom: 10px;
}
.objectives-container,
.personal-details-container,
.skills-container {
  padding-top: 15px;
  padding-right: 15px;
  padding-bottom: 0px;
  padding-left: 15px;
  background-color: #fff;
  border-top: solid 5px #003d76;
  border-bottom: solid 5px #ddd;
}
.skills-container {
  padding-bottom: 15px;
}
.personal-details-container div.bordered:first-child {
  padding-top: 15px;
}
.btn-primary:hover,
.btn-primary:focus,
.btn-primary:active,
.btn-primary.active,
.open .dropdown-toggle.btn-primary,
button.btn-yes {
  color: #fff;
  background-color: #004280;
  border-color: transparent;
}
.btn:active,
.btn.active {
  background-image: none;
  outline: 0;
  webkit-box-shadow: none;
  box-shadow: none;
}
#viewOne .btn,
#viewTwo .btn,
#viewThree .btn {
  text-align: left;
  line-height: 2.2;
  margin-bottom: 10px;
}
.btn-list {
  pointer-events: none;
  cursor: not-allowed;
  text-decoration: none;
}
#viewOne .btn-block + .btn-block,
#viewTwo .btn-block + .btn-block,
#viewThree .btn-block + .btn-block {
  margin-top: 0;
}
.spacer20 {
  margin-top: 20px;
  /*
      height: 20px;
      clear: both;
  */
}
.gap20 {
  height: 20px;
  clear: both;
}
.spacer {
  margin-bottom: -1px;
  background-color: #fff;
  border-bottom-color: #dddddd;
  border-bottom-style: solid;
  border-bottom-width: 3px;
}
.spacer a {
  text-transform: uppercase;
  font-size: 12px;
  padding: 14px 16px;
  color: #ddd;
}
.spacer a:hover {
  text-decoration: none;
}
.loginBtn {
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  border-bottom-color: #dddddd;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  line-height: 1.33;
  display: block;
  width: 100%;
  color: blue;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
}
.logoutBtn {
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  line-height: 1.33;
  display: block;
  width: 100%;
  color: blue;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
}
.helpBtn {
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  line-height: 1.33;
  display: block;
  width: 100%;
  color: blue;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
}
.adminBtn {
  border-right-color: #dddddd;
  border-right-style: solid;
  border-right-width: 1px;
  border-left-color: #dddddd;
  border-left-style: solid;
  border-left-width: 1px;
  line-height: 1.33;
  display: block;
  width: 100%;
  color: blue;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
}
.adminOption .adminBtn {
  border-left: none;
}
.adminOption a {
  font-size: 0.9em;
  padding-left: 0;
  padding-right: 0;
}
.colLogOut,
.colAdmin {
  padding-right: 0px;
}
.colHelp,
.colAdmin {
  padding-left: 0px;
}
.colHelp {
  padding-right: 15px;
}
.contact-image {
  width: 40px;
  height: 49.47368px;
  margin: -3px 0 5px -5px;
}
/* New CSS for nav bar categories end */
.flexMenu-popup {
  padding: 0;
  background-color: #0E0F10;
  margin: 0;
  z-index: 200;
  list-style: none;
  right: 0;
  left: auto;
}
.flexMenu-viewMore > a,
.flexMenu-viewMore > a:hover {
  background-color: #5599AA;
}
.flexMenu-viewMore.active > a,
.flexMenu-viewMore.active > a:hover {
  background-color: #088;
}
.flexMenu-popup > li > a {
  color: #ddd;
  display: block;
  text-decoration: none;
  padding: 10px 20px;
  clear: both;
  font-weight: normal;
  line-height: 1.42857143;
  white-space: nowrap;
  border-bottom: solid 1px #383E44;
}
.flexMenu-popup > li > a:hover {
  background-color: #262E35;
}
.breadcrumb {
  padding-top: 3px;
  padding-right: 15px;
  padding-bottom: 3px;
  padding-left: 5px;
  list-style: none;
  background-color: transparent;
  margin-bottom: 0px;
  text-transform: uppercase;
  font-size: 11px;
}
.marginSpacer {
  margin-left: 70px;
}
.remove-top-bottom-padding {
  background-color: #FFFFFF;
  padding-top: 3px;
  padding-right: 5px;
  padding-bottom: 3px;
  padding-left: 57px;
  margin-bottom: 0px;
  margin-left: 63px;
  font-size: 11px;
  text-transform: uppercase;
}
.remove-bottom-bottom-padding {
  margin-top: 0px;
  height: 64px;
}
.remove-left-padding {
  padding-left: 0px;
  padding-right: 15px;
  height: 105px;
  width: inherit;
}
.userProfile {
  color: #333;
  background-color: #fff;
  padding-top: 16px;
  padding-right: 13px;
  padding-bottom: 16px;
  padding-left: 34px;
  margin-left: 81px;
  margin-top: 25px;
  margin-bottom: 15px;
  z-index: 10;
  line-height: 16px;
  font-weight: bold;
}
.teamProfile {
  color: #475055;
  background-color: #fff;
  padding-left: 10px;
  padding-top: 12px;
  z-index: 10;
  line-height: 1em;
  font-size: 13px;
  text-transform: uppercase;
}
.userProfileImg {
  position: absolute;
  margin-top: -7px;
  margin-left: 22px;
  z-index: 999;
  padding: 0;
}
.activity_rounded {
  display: inline-block;
  -webkit-border-radius: 50%;
  -moz-border-radius: 50%;
  border-radius: 50%;
  -khtml-border-radius: 50%;
  border: 6px solid #fff;
}
.activity_rounded img {
  -webkit-border-radius: 50%;
  -moz-border-radius: 50%;
  border-radius: 50%;
  -khtml-border-radius: 50%;
  vertical-align: middle;
  width: 100px;
  height: 100px;
}
.setMargins {
  margin-top: 25px;
  margin-bottom: 15px;
}
.activeUserBlue {
  /*  color: #3bafda;*/
  color: #00529f;
}
#context_div .activeUserBlue {
  display: inline;
}
/* override bootstrap accordion styles - general */
.list-group-item {
  background-color: #0E0F10;
  border: none;
  color: #ffffff;
  font-size: 15px;
  width: 100%;
  border-radius: 0 !important;
  position: relative;
}
a.list-group-item.active,
a.list-group-item.active:hover {
  background-color: #262B31;
  border-top: solid 1px #1B1E22;
  border-bottom: solid 1px #383E44;
  margin-bottom: 0;
  margin-top: 0;
}
a.static-link.list-group-item.active,
a.static-link.list-group-item.active:hover {
  background-color: #262B31;
  border-top: solid 1px #1B1E22;
  border-bottom: solid 1px #383E44;
  margin-bottom: 0;
  margin-top: 0;
}
a.list-group-item-text,
a.list-group-item.active {
  color: #ffffff !important;
  font-size: 15px;
  margin-right: 40px;
}
.badge,
a.list-group-item.active > .badge {
  background-color: #00529f;
  color: #ffffff;
  font-size: 13px;
  width: 35px;
  -moz-border-radius: 10px;
  border-radius: 10px;
  position: absolute;
  /* relative to list-group-item */
  top: 12px;
  right: 10px;
}
.badge-tile {
  background-color: #001d39;
}
.accordion-toggle-image {
  width: 10px;
  float: left;
}
.category-text {
  margin-left: 30px;
  margin-right: 50px;
}
.other-text {
  margin-left: 45px;
  margin-right: 50px;
}
.nav-menu-close,
.org-menu-close {
  color: #ffffff;
  cursor: pointer;
}
.panel-heading_REMOVE {
  margin-top: 0 !important;
}
.panel-group {
  margin-bottom: 0 !important;
}
.panel-group .panel {
  border-radius: 0;
}
.panel-group .panel + .panel {
  margin-top: 0 !important;
}
img.img-circle.contact-image {
  height: 45px;
  width: 45px;
}
.nav-left-mobile a {
  background-color: #ffffff;
  background-image: url('../images/hamburger.png');
  margin-top: 20px;
  border: 1px solid #d3d3d3;
  border-radius: 3px;
  -webkit-border-radius: 3px;
  -moz-border-radius: 3px;
}
.header {
  background-color: #ffffff;
  position: relative;
  z-index: 100;
  height: 100px;
  left: 10px;
}
#header {
  background-color: #ffffff;
  color: grey;
}
#header a {
  background-image: none;
  /* stop hamburger showing under contact image for org menu */
}
.nav-group-header {
  background-color: #3A434E;
  border-bottom: 2px solid #0E0F10;
}
/* END override bootstrap accordion styles - general  */
/* Override bootstrap accordion styles - Contact details and right org menu */
#organization-right {
  background-color: #E9EDEF;
  height: 100%;
  padding: 0;
}
.organization-right {
  margin-top: 0px;
}
.organization-right .list-group {
  margin-bottom: 0;
}
.organization-right .list-group-item {
  /* different accordion styles for right hand org menu - on canvas */
  background-color: #005aae;
  color: #ffffff;
  border-top-color: #004586;
  border-bottom-color: #0072dc;
  border-bottom-width: 1px;
  border-top-width: 1px;
  border-left: none;
  border-right: none;
}
.organization-right .panel-group {
  /* line up right org menu with banner login info*/
  margin-left: 15px;
  margin-right: 15px;
}
#organization-right .panel-default > .panel-heading {
  padding: 20px 20px 45px 20px;
}
.org-right a.list-group-item.active,
.organization-right a.list-group-item.active {
  /* different accordion styles for right hand org menu - on canvas */
  background-color: #005aae;
  border-top-color: #004586;
  border-bottom-color: #0072dc;
  border-bottom-width: 1px;
  border-top-width: 1px;
  border-left: none;
  border-right: none;
}
.org-heading-text {
  margin-left: 30px;
  margin-right: 20px;
}
.contactAccordion {
  /* line up right org menu with banner login info*/
  margin-left: -15px;
  margin-right: -15px;
}
#menu-right a.list-group-item.active,
#menu-right a.list-group-item.active {
  /* different accordion styles for right hand org menu - off canvas */
  background-color: #005aae;
  border-top-color: #004586;
  border-bottom-color: #0072dc;
  border-bottom-width: 1px;
  border-top-width: 1px;
  border-left: none;
  border-right: none;
}
#menu-right .list-group-item {
  /* different accordion styles for right hand org menu - off canvas */
  background-color: #005aae;
  border-top-color: #004586;
  border-bottom-color: #0072dc;
  border-bottom-width: 1px;
  border-top-width: 1px;
  border-left: none;
  border-right: none;
  color: #ffffff;
}
#menu-right .search-container .input-group {
  margin-left: 0;
  margin-right: 0;
  margin-bottom: 0;
}
#menu-right .search-container .panel-heading {
  padding-left: 15px;
}
#menu-right .search-container .panel-body {
  padding-left: 15px;
}
#menu-right .list-group {
  margin-bottom: 0;
}
#menu-right a.list-group-item-text {
  padding-left: 13px;
}
#menu-right .panel-heading {
  padding-left: 30px;
}
#menu-right .panel-default > .panel-heading {
  padding: 20px 20px 45px 20px;
}
#menu-right .panel-body {
  padding-left: 25px;
}
#menu-right .search-container .contact-show-hide {
  margin-left: 88%;
}
.search-container .panel .panel-default {
  margin-bottom: -10px;
}
.search-container {
  padding-bottom: 0;
}
.search-container .input-group {
  margin-left: 15px;
  -webkit-margin-end: 14px;
  /* weird chrome behaviour for right margin */
  margin-right: 15px;
  padding: 10px 10px 10px 10px;
  background-color: #004586;
}
.search-div {
  border-bottom: 1px solid #0072dc;
  border-top: 1px solid #0072dc;
}
.search-close {
  background-color: #d3d3d3 ;
  position: absolute;
  top: 20px;
  right: 60px;
  z-index: 10;
  cursor: pointer;
  width: 14px;
  /* or whatever you want */
  height: 14px;
  /* or whatever you want */
  line-height: 11px;
  /* or whatever you want, should match height */
  text-align: center;
}
.search-close > img {
  vertical-align: middle;
}
/*#menu-right .search-close {*/
/*width: 4%;*/
/*}*/
::-webkit-input-placeholder {
  color: #8E99A0 !important;
  font-size: 14px;
}
:-moz-placeholder {
  /* Firefox 18- ./
    color: #8E99A0 !important;
    font-size: 14px;
}

::-moz-placeholder {  /* Firefox 19+ */
  color: #8E99A0 !important;
  font-size: 14px;
}
:-ms-input-placeholder {
  color: #8E99A0 !important;
  font-size: 14px;
}
.search-div .btn-primary {
  color: #8E99A0 ;
  background-color: white;
  border: 1px solid #ffffff;
  border-radius: 0;
}
.search-container .panel-heading {
  background-color: #ffffff;
}
.search-container .contactAccordion {
  margin-left: 0;
  margin-right: 0;
}
.search-input {
  border-radius: 0 !important;
  border-left: 0;
  border-top: 0;
  border-bottom: 0;
  border-right: 1px solid #ffffff;
}
.search-button {
  border-left: 2px solid #d3d3d3 !important;
}
/*.search-input:focus, .search-input:active {
    border-right-color: #8E99A0 !important;
    border-left: 0;
    border-top: 0;
    border-bottom: 0;
}

.btn-primary:focus, .btn-primary:active {
    border-color: #8E99A0 !important;
}*/
.search-no-results {
  /* on canvas org menu */
  margin-right: 15px;
  margin-left: 15px;
}
#menu-right .search-no-results {
  /* off canvas org menu */
  margin-right: 0;
  margin-left: 0;
}
.contact_heading.panel-heading {
  background-color: #ffffff;
}
.user-image-div {
  float: left;
  padding-right: 7%;
}
.user-name {
  cursor: default !important;
  padding: 10px 0 5px 0;
  font-size: 14px;
  font-weight: normal;
  color: #475055;
}
.user-name:hover {
  text-decoration: underline;
}
.contact_heading a {
  text-decoration: none !important;
}
.user-job {
  margin-bottom: -20px;
  font-size: 13px;
  font-weight: normal;
  margin-right: 40px;
  margin-left: 40px;
  padding-left: 7%;
  color: #8f9395;
}
.user-job:hover {
  text-decoration: underline;
}
.contact-details {
  font-size: 13px;
  color: #737e84;
  padding: 5%;
}
.contact-details.org-menu-link {
  color: #00529f;
}
div.contact_heading.panel {
  position: relative;
}
.contact-show-hide img.contact-shown {
  padding: 14px 10px 14px 10px;
  border: 2px solid #d3d3d3;
  border-bottom: 3px solid #ffffff;
  position: relative;
  /* margin-bottom: -45%;   */
  /* fix tab position relative to panel */
  margin-bottom: -73px;
}
.contact-show-hide img.contact-hidden {
  padding: 10px;
  border: 2px solid #d3d3d3;
  border-bottom: 1px solid #ffffff;
  position: absolute;
  bottom: -1px;
  /* fix tab position relative to panel */
}
.contact-show-hide {
  cursor: pointer !important;
  margin-left: 85%;
}
a.org-menu-link {
  color: #00529f;
}
/* END Override bootstrap accordion styles - Contact details and right org menu */
/* Styles for Tiles */
.tile-container {
  position: relative;
  width: 100%;
  height: 300px;
  padding: 7px;
  color: #515151;
  background-color: #fff;
  border: thin solid #f1f1f1;
  overflow: hidden;
  -webkit-border-radius: 3px !important;
  -moz-border-radius: 3px !important;
  border-radius: 2px !important;
  -webkit-box-shadow: 2px 2px 0 rgba(95, 95, 95, 0.1) !important;
  -moz-box-shadow: 2px 2px 0 rgba(95, 95, 95, 0.1) !important;
  -ms-box-shadow: none;
  -o-box-shadow: none;
  box-shadow: 2px 2px 0 rgba(95, 95, 95, 0.1) !important;
}
.tile-container a {
  height: 300px !important;
  text-decoration: none;
}
.tile-container .richTextTile a {
  text-decoration: underline;
}
.tile-heading h4 {
  width: 100%;
  margin: 0;
  padding: 7px 7px 7px 0;
  background-color: #0072dc;
  padding-left: 5%;
  border-bottom: 3px solid #004586;
}
#process-views .tile-heading h4 {
  color: white;
}
.tile-image {
  display: block;
  width: 100%;
  height: 300px;
}
/*.tile-container-title {
  border-bottom: 3px solid @defaultThemeSectionLabelBorder;
}*/
.tile-content {
  height: 260px;
}
.tile-item-header {
  font-size: 0.9em;
  margin-bottom: 1px;
}
.tile-item {
  margin-top: -2px;
  margin-bottom: 2px;
  border: 3px solid #ddd;
  padding: 2px;
  font-size: 0.9em;
}
.tile-item-none {
  margin-top: 20px;
}
.summary-tile,
.summary-tile-none {
  border: 5px solid #00529f;
  font-size: 5em;
  text-shadow: 2px 2px lightgrey;
  text-align: center;
  height: 200px;
  line-height: 200px;
}
.summary-tile-none {
  font-size: 2em;
  text-shadow: none;
}
table.objectives-tile,
table.personal-details-tile,
table.work-details-tile {
  width: 100%;
  margin-top: 10px;
  margin-left: auto;
  margin-right: auto;
  table-layout: fixed;
}
table.objectives-tile tr,
table.personal-details-tile tr {
  height: 20px;
  border-bottom: solid 7px #ffffff;
}
table.personal-details-tile tr {
  border-bottom: none;
}
table.personal-details-tile td {
  overflow: hidden;
  word-wrap: break-word;
}
.personal-details-content {
  padding-left: 5px;
  padding-right: 5px;
}
.objective-summary-name,
.objectives-none-active,
.personal-details-label {
  color: #ffffff;
  font-size: 1.1em;
  padding: 3% 5%;
  background-color: #00529f;
}
.personal-details-label,
.personal-details-value {
  font-size: 0.9em;
  padding: 0% 2%;
}
div.objectives-none-active {
  width: 100%;
  margin-top: 10px;
}
.objective-summary-name,
.personal-details-label {
  width: 90%;
}
.objective-summary-progress {
  width: 10%;
  padding-left: 5%;
  padding-right: 5%;
  background-color: #3284a8;
}
.no-progress,
.above-track,
.on-track,
.below-track {
  width: 10px;
  height: 10px;
  margin: 10px 5%;
  border: 1px solid #dddddd;
}
.no-progress {
  background-color: #ffffff;
}
.above-track {
  background-color: green;
}
.on-track {
  background-color: gold;
}
.below-track {
  background-color: red;
}
/* END styles for Tiles */
/* Modal window styles */
.modal-content {
  /* override bootstrap rounded corners */
  border-radius: 0;
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
  color: #7e7e88;
}
.modal-header {
  background-color: #f1f2f6;
  height: 48px;
}
.modal-header.long-message {
  height: 70px;
}
.modal-body h4 {
  margin-bottom: 0;
}
.modal-body.manager-notes {
  padding: 15px;
}
.modal-title {
  color: #86878c;
  padding-bottom: 15px;
}
.modal-teammember-name {
  color: #00529f;
}
.modal-footer {
  /* override bootstrap style */
  margin-top: 0;
  border-top: none;
}
.modal-footer-buttons {
  background-color: #f1f2f6;
  padding: 20px;
  margin-left: -20px;
  margin-right: -20px;
  margin-bottom: -20px;
  margin-top: 20px;
}
div.input-container {
  margin-bottom: 20px;
}
div.input-container:last-child {
  margin-bottom: -30px;
}
.modal-cancel,
.modal-save,
.modal-create-approve,
.modal-save-approve,
.modal-approve {
  font-weight: bold;
  color: #86878c;
  line-height: 0.5;
  height: 30px;
}
.modal-cancel,
.modal-save,
.modal-approve {
  font-size: 14px;
  width: 75px;
}
.modal-approve {
  width: 85px;
}
.modal-cancel {
  background-color: #ffffff;
}
.modal-save,
.modal-create-approve,
.modal-approve {
  color: #ffffff;
  background-color: #00529f;
  border-color: #0072dc;
}
.modal-create-approve {
  width: 180px;
  font-size: 12px;
}
.modal-close {
  background-color: #4a525d;
  width: 48px;
  height: 48px;
  margin: -15px -15px 0 0;
  border: 10px solid #e4e7ec;
}
.modal-close img {
  display: block;
  margin: auto;
  margin-top: 9px;
  /* center the cross to close the modal */
}
.modal-label {
  background-color: #00529f;
}
.modal-attachment {
  margin-left: -20px;
}
.modal-label-border {
  width: 598px;
  margin-left: -15px;
  margin-bottom: 10px;
  height: 5px;
  background-color: #003d76;
  margin-top: 0px;
}
.dependants .modal-label-border {
  margin-left: -20px;
}
.dependants span.long-label {
  font-size: 13px;
  padding-bottom: 9px;
}
.section-label {
  background-color: #00529f;
}
.section-label-border {
  margin-left: -15px;
  margin-bottom: 10px;
  height: 5px;
  background-color: #003d76;
  margin-top: 0px;
}
input.group1,
textarea.group1 {
  width: 568px !important;
  /* 598 - 15px margin either side */
  margin-bottom: 15px !important;
}
textarea.group1-last {
  width: 568px !important;
  /* 598 - 15px margin either side */
  margin-bottom: 0px !important;
}
input.input-error.ng-invalid.ng-dirty,
textarea.input-error.ng-invalid.ng-dirty,
textarea.input-error.ng-invalid.ng-dirty,
input.input-error.ng-invalid.ng-dirty,
.server-error {
  color: #e74e24;
  background-color: #feede8;
  border: 1px solid #e43600;
}
.server-error {
  width: 90%;
  margin-top: -40px;
}
.server-error table {
  margin-bottom: 0px;
}
.process-error,
.action-error {
  margin-top: 40px;
}
div.modal-date {
  width: 100%;
  margin-bottom: 15px !important;
  margin-left: -15px;
}
.absence-reason div.modal-date {
  padding-left: 30px;
  padding-right: 30px;
}
.absence-reason .panel-default > .panel-heading + .panel-collapse .panel-body {
  border-top: none;
}
div.modal-date-review {
  width: 100%;
  margin-bottom: 15px !important;
  margin-left: 0px;
  padding-right: 43px;
}
.expected-date {
  padding-right: 45px;
  margin-bottom: 15px;
}
.attribute-picklist select {
  width: 269px;
}
.datepicker input {
  cursor: pointer;
}
.datepicker .date-focus {
  width: 100%;
  cursor: pointer;
  height: 34px;
}
.datepicker div.arrow-container.date-blur,
.datepicker div.arrow-container.date-focus {
  float: left;
  width: 34px !important;
  height: 34px;
  border: #ccc 1px solid;
  background-color: white;
  position: absolute;
  right: 0px;
  z-index: 100;
}
.datepicker div.arrow-container.date-focus {
  background-color: #00529f;
  position: absolute;
}
/*.fieldsets .datepicker div.arrow-container.date-blur, .fieldsets .datepicker div.arrow-container.date-focus {
  right: 15px;
}*/
.datepicker label {
  font-weight: normal;
}
span.modal-error {
  font-size: 12px;
  font-weight: bold;
  text-transform: none;
  background-color: #ffffff;
  color: #e74e24;
  margin-right: 15px;
}
.modal-error-mobile {
  display: none;
}
.attribute-input {
  padding-right: 30px;
  margin-bottom: 15px;
}
.attribute-input-number {
  width: 50%;
  padding-left: 0;
  margin-bottom: 15px;
}
.hr-request .attribute-input-number {
  width: 100%;
}
.attribute-input-review,
.attribute-input-days {
  margin-bottom: 15px;
}
.time-off {
  margin-left: -15px;
  padding-left: 0;
}
.readonly-fields {
  margin-left: -15px;
  margin-bottom: 20px;
}
.attribute-picklist,
.attribute-picklist-review {
  padding-left: 0;
  padding-right: 15px;
  margin-bottom: 15px;
  clear: left;
}
.attribute-picklist-review,
.attribute-textarea {
  padding-left: 16px;
}
.optional-attributes .attribute-input {
  margin-left: -15px;
}
.optional-attributes .attribute-picklist {
  margin-left: 0px;
}
/*.attribute-list {
    margin-bottom: 15px;
}*/
.attribute-list .attribute-checkbox {
  margin-left: -30px;
  margin-top: -15px;
}
.attribute-checkbox {
  margin-left: -15px;
  padding-left: 0;
  /*    margin-top: 15px;*/
  margin-bottom: 15px;
}
div.select-team-member {
  margin-bottom: 20px;
}
div.select-team-member {
  margin-top: 20px;
}
.select-div {
  width: 100%;
  height: 34px;
  line-height: 34px;
  overflow: hidden;
  border: #ccc 1px solid;
  margin: 0px;
  padding: 0px;
  float: left;
}
.select-arrow.select-div-blur,
.select-arrow.date-blur {
  width: 0 !important;
  height: 0;
  border-left: 7px solid transparent;
  border-right: 7px solid transparent;
  border-top: 7px solid #00529f;
  margin-left: 9px !important;
  margin-top: 12px;
}
.select-arrow.select-div-focus,
.select-arrow.date-focus {
  width: 0 !important;
  height: 0;
  border-left: 7px solid transparent;
  border-right: 7px solid transparent;
  border-top: 7px solid white;
  margin-left: 9px !important;
  margin-top: 12px;
}
.arrow-container {
  float: right;
  width: 34px !important;
  height: 34px;
  border-left: #ccc 1px solid;
}
.arrow-container.select-div-blur {
  background-color: white;
}
.arrow-container.select-div-focus {
  background-color: #00529f;
}
.select-default {
  padding-left: 8px;
}
.select-div select,
.select-div input {
  margin: 0px;
  margin-top: -35px !important;
  padding: 0px;
  opacity: 0;
  filter: alpha(opacity=0);
  width: 100%;
  height: 100%;
  display: block;
  cursor: pointer;
}
.fieldsets .select-div,
.fieldsets .select-div-blur,
.fieldsets .select-div-focus {
  width: 50%;
  margin-left: -15px;
}
.fieldsets .fieldset-date {
  padding-left: 0;
  padding-right: 15px;
}
.quarters-list {
  position: absolute;
  top: 0px;
  left: 266px;
  width: 100px;
  padding-left: 16px;
  padding-top: 1px;
}
.quarters-list li {
  background-color: #32373d;
  border-bottom: 1px solid #fefffd;
  list-style: none;
  padding: 0px;
}
.quarters-list li a {
  color: #ffffff !important;
  text-decoration: none;
  display: block;
  padding: 3.5px 12px;
  cursor: pointer;
}
.quarters-list li a:hover {
  background-color: #00529f;
}
.datepicker .btn-default {
  background-color: #3e454d;
  color: #ffffff !important;
}
.datepicker .btn-default {
  padding: 6px 11px;
}
.datepicker .btn-default:hover {
  background-color: #00529f !important;
}
.datepicker thead tr th .btn-default:hover {
  background-color: #3e454d !important;
  border: none;
}
.datepicker tr.h6 {
  line-height: 3 !important;
  background-color: #3e454d;
  color: #ffffff !important;
}
div.datepicker table {
  background-color: #3e454d !important;
  width: 205px;
  border-right: 2px solid #ffffff;
}
th.absences-table {
  width: 15%;
}
.currency-amount,
.currency-percentage {
  margin-right: 10px;
}
.currency-amount {
  width: 15%;
  margin-left: 15px;
}
.currency-percentage {
  width: 10%;
  margin-left: 10px;
}
.hr-request-fieldsets input,
.hr-request-fieldsets .hr-request-date .hr-request-date-div {
  margin-top: -10px;
}
.hr-request-fieldsets .hr-request-date input {
  margin-top: 0px;
}
.hr-request-fieldsets div.select-div {
  margin-top: -10px;
  width: 50%;
}
select.autocomplete {
  margin-top: 0;
  position: relative;
  z-index: 999;
}
.autocomplete option {
  position: relative;
  z-index: 999;
}
.btn .badge {
  color: #fff;
  /*    background-color: #2096c8;*/
  background-color: #00529f;
  width: 25px;
  margin-top: -15px;
  margin-right: -35px;
}
.badge-tile {
  background-color: #00529f;
}
/* END Modal window styles */
/* MEDIA QUERIES */
@media (max-width: 1650px) {
  .adminOption a {
    font-size: 0.8em;
  }
}
@media (max-width: 1450px) {
  .adminOption a {
    font-size: 0.7em;
  }
}
@media (max-width: 1350px) {
  .adminOption a {
    font-size: 0.6em;
  }
}
@media (min-width: 1200px) {
  /*only visible on lg */
  .nav-menu-header-mobile {
    display: none;
  }
  .toggle-btn {
    display: block !important;
    background-color: #3A434E;
    border-bottom-left-radius: 30px;
    border-bottom-right-radius: 30px;
    height: 15px;
    width: 110px;
    /* margin: 0 auto; */
    background-color: #F1F1F1;
    z-index: 999999;
    /* position: absolute; */
    /* left: 45%; */
    position: absolute;
    left: 0;
    right: 0;
    margin-left: auto;
    margin-right: auto;
    cursor: pointer;
    transition: .8s;
  }
  .toggle-btn:hover {
    background-color: #00529f;
  }
  .toggle-btn img {
    position: absolute;
    margin-top: auto;
    margin-right: auto;
    margin-bottom: auto;
    margin-left: auto;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 5px;
    height: 5px;
  }
  .row.table-row {
    display: table;
    width: 100%;
    margin: 0 auto;
  }
  .row.table-row > [class*="col-"] {
    float: none;
    display: table-cell;
    vertical-align: top;
    height: 100% !important;
  }
  .row.table-row > .col-lg-12 {
    width: 100%;
  }
  .row.table-row > .col-lg-11 {
    width: 91.66666667%;
  }
  .row.table-row > .col-lg-10 {
    width: 83.33333333%;
  }
  .row.table-row > .col-lg-9 {
    width: 75%;
  }
  .row.table-row > .col-lg-8 {
    width: 66.66666667%;
  }
  .row.table-row > .col-lg-7 {
    width: 58.33333333%;
  }
  .row.table-row > .col-lg-6 {
    width: 50%;
  }
  .col-lg-5 {
    width: 41.66666667%;
  }
  .col-lg-4 {
    width: 33.33333333%;
  }
  .row.table-row > .col-lg-3 {
    width: 25%;
  }
  .row.table-row > .col-lg-2 {
    width: 16.66666667%;
  }
  .row.table-row > .col-lg-1 {
    width: 8.33333333%;
  }
}
@media (max-width: 1199px) {
  textarea.group1-last {
    margin-bottom: 20px !important;
  }
  div.modal-date.last-form-element,
  div.last-form-element {
    margin-bottom: 30px !important;
  }
  .modal-date {
    margin-bottom: 15px;
  }
  .attribute-input {
    margin-left: 0px;
  }
  .attribute-picklist-review {
    padding-right: 15px;
  }
  .attribute-input-review {
    padding-left: 16px;
  }
  .modal-footer-buttons {
    margin-top: 0px;
  }
  .absence-reason div.modal-date {
    padding-right: 0;
  }
  .attribute-list-container .attribute-picklist {
    padding-right: 15px;
  }
}
@media (min-width: 992px) {
  /*only visible on md and lg */
  .org-menu-header-mobile {
    display: none;
  }
  .absences-team-balances-table .table > thead > tr > th {
    font-size: 11px;
  }
  /*    #organization-right .panel-default > .panel-heading + .panel-collapsing .panel-body {
          margin-top: -10%;
      }

      #organization-right .panel-default > .panel-heading + .panel-collapse .panel-body {
          margin-top: -10%;
      }*/
}
@media (min-width: 992px) and (max-width: 1199px) {
  /*only visible on md */
  #client-logo {
    z-index: 101;
    position: absolute;
    top: 8px;
    left: 60px;
    height: 60px;
  }
  #banner-info {
    z-index: 101;
    position: absolute;
    top: 8px;
    right: 0px;
    height: 60px;
  }
}
@media (min-width: 750px) and (max-width: 1199px) {
  .reason-padding-right {
    padding-right: 0;
  }
}
@media (max-width: 991px) {
  #banner-info {
    display: none;
  }
  #header {
    /* right org menu icon */
    z-index: 102;
    position: absolute;
    top: 8px;
    right: 0px;
  }
  div#header {
    padding-left: 0px;
  }
  div#client-logo-mobile {
    /* change logo position for mobile and portrait tablet */
    float: left;
    height: 80px;
    width: 95.5%;
    /* fallback for browsers not supporting calc */
    width: calc(60%);
    /* centering client logo in banner */
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
    margin-left: 20px;
    margin-top: -20px;
    padding-top: 10px;
    border-left: 1px solid #dddddd;
    border-right: 1px solid #dddddd;
  }
  div#client-logo-mobile > img {
    height: 60px;
    width: 57px;
    margin-left: 48%;
    /* fallback for browsers not supporting calc */
    margin-left: calc(21.5%);
    /* centering client logo in banner */
    margin-left: -webkit-calc(21.5%);
    margin-left: -moz-calc(21.5%);
  }
  .header {
    height: 60px;
    margin-top: 20px;
    left: 0px;
    margin-right: 0px;
  }
  .nav-left-mobile a {
    margin-top: 0;
  }
  .indent-1 {
    padding-left: 15px;
  }
  .indent-2 {
    padding-left: 30px;
  }
  .indent-3 {
    padding-left: 30px;
  }
  .contact-show-hide img.contact-shown {
    margin-bottom: -73px;
    /* fix tab position relative to panel */
  }
}
@media (max-width: 920px) {
  div#client-logo-mobile {
    /* change logo position for mobile and portrait tablet */
    width: 95.5%;
    /* fallback for browsers not supporting calc */
    width: calc(60%);
    /* centering client logo in banner */
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  div#client-logo-mobile > img {
    margin-left: 45%;
    margin-left: calc(21.5%);
    margin-left: -webkit-calc(21.5%);
    margin-left: -moz-calc(21.5%);
  }
  #sub-section {
    padding-left: 15px !important;
  }
  .userProfileImg {
    margin-top: -10px;
    margin-left: 15px;
  }
  .userProfileImg img {
    /*width: 95px;*/
    /*height: 95px;*/
  }
  div.h3 {
    margin-top: 0px;
  }
  #process-views {
    margin-top: 0px;
  }
  .label-table {
    margin-left: 0;
  }
}
@media (min-width: 921px) and (max-width: 1279px) {
  .userProfileImg {
    margin-top: -10px;
    margin-left: 17px;
  }
  .userProfileImg img {
    /*width: 95px;*/
    /*height: 95px;*/
  }
  div.h3 {
    margin-top: 0px;
  }
  .panel div.h3 {
    margin-top: 15px !important;
  }
  #process-views {
    margin-top: 0px;
  }
}
@media (max-width: 850px) {
  div#client-logo-mobile {
    width: 94.5%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
}
@media (min-width: 768px) and (max-width: 1200px) {
  .absences-team-balances-table {
    margin-top: 30px;
    margin-bottom: 0px;
  }
}
@media (max-width: 767px) {
  .absences-team-balances-table {
    padding-left: 0;
    padding-right: 0;
    margin-top: 0px;
    margin-bottom: 15px;
  }
}
@media (max-width: 775px) {
  /*only visible on xs, wider than 768px to allow for vertical scrollbar on some devices */
  div#client-logo-mobile {
    border: none;
    width: 92%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  .nav-tabs > li {
    float: left;
    margin-bottom: 0px;
    border-right-color: #727272;
  }
  div.row.spacer {
    padding-right: 10px;
  }
  div#context_div {
    margin-right: -15px;
  }
  .userProfile {
    margin: 0;
    padding-top: 0;
    padding-bottom: 0;
    padding-top: 1%;
    align-content: center;
    padding-left: 3%;
    font-size: 11px;
    float: left;
  }
  div.teamProfileDetailsMobile {
    padding: 0;
    margin-bottom: 20px;
    background-color: #dbdbdb;
    display: block;
    width: 100%;
    height: 60px;
  }
  .teamProfileDetailsMobile img {
    margin-left: 0px;
    margin-right: 10px;
    margin-top: 0px;
    -webkit-border-radius: 50%;
    -moz-border-radius: 50%;
    border: 4px solid #ffffff;
    border-radius: 50%;
    -khtml-border-radius: 50%;
    vertical-align: middle;
    width: 70px;
    height: 70px;
  }
  #sub-section .panel > .panel-collapse .panel-body {
    padding-top: 0;
  }
  .activeUserLabel {
    display: none;
  }
  #mobile_categories {
    margin-top: 20px;
  }
  .userProfileImg {
    margin-left: 7px;
  }
  .objectives-panel-body {
    padding-top: 0px;
  }
  .img-container {
    float: left;
    height: 70px;
    width: 100px;
    background-color: #F0F2F5;
    margin-left: 10px;
    margin-right: 0px;
    border: 1px solid #E4E7EC;
  }
  .profile-details {
    height: 70px;
    float: left;
    width: 61%;
    margin-top: 0px;
  }
  .profile-contact {
    color: black;
    font-size: 11px;
    float: left;
    margin-left: 3%;
    clear: left;
    width: 100%;
    height: 50%;
  }
  .profile-text {
    width: 100%;
    height: 50%;
    margin: 0;
    padding-top: 0;
    padding-bottom: 0;
    padding-top: 1%;
    margin-left: 3%;
    font-size: 11px;
    float: left;
  }
  .contact-button {
    background-color: #F0F2F5;
    border: 1px solid #E4E7EC;
    width: 29%;
    height: 25px;
    padding: 1% 0 1% 2%;
    text-align: center;
    margin-left: 3%;
    float: left;
    font-size: 1em;
    line-height: 1.5em;
  }
  a.contact-button {
    color: #838383;
    text-decoration: none;
  }
  #context_div {
    height: 70px;
    margin-top: 60px;
    margin-right: -25px;
    margin-left: -15px;
    border-top: 1px solid #E4E7EC;
    border-bottom: 1px solid #E4E7EC;
  }
  .fixed-top {
    position: fixed;
    top: 0;
    left: 0;
  }
  .absolute-menu {
    position: absolute;
    top: 0;
  }
  .mobile-wrapper {
    height: 80px;
    width: 100%;
    background-color: white;
    z-index: 1000;
    display: block;
  }
  .modal-dialog {
    width: 600px;
    margin-left: auto;
    margin-right: auto;
  }
  .modal-error-non-mobile {
    display: none;
  }
  span.modal-error {
    font-size: 12px;
    margin-right: 0px;
  }
  div.modal-error-mobile {
    display: block;
    /*        width: 270px;*/
    margin-bottom: 15px;
  }
  .modal-label-border {
    width: 598px;
    margin-left: -15px;
  }
  h4.modal-title {
    font-size: 12px;
  }
  .modal-body h4 {
    -webkit-margin-after: -1px;
    /* fix 1px gap between label and border in Android browser */
  }
  .next-review {
    margin-top: 0px;
  }
  .attribute-picklist {
    padding-right: 15px;
  }
  .attribute-picklist-fieldset {
    padding-right: 0;
  }
  .attribute-input-number {
    width: 100%;
  }
  .attribute-text {
    padding-right: 15px;
  }
  .attribute-input-review {
    padding-right: 30px;
  }
  .fieldsets .select-div,
  .fieldsets .select-div-blur,
  .fieldsets .select-div-focus,
  .absence-reason .select-div,
  .absence-reason .select-div-blur,
  .absence-reason .select-div-focus {
    width: 100%;
  }
  .hr-request-fieldsets div.select-div,
  .hr-request-fieldsets div.select-div-blur,
  .hr-request-fieldsets div.select-div-focus {
    width: 100%;
    margin-bottom: 15px;
    float: none;
  }
  .modal-date {
    padding-right: 0px;
  }
  .expected-date {
    padding-right: 30px;
  }
  .fieldsets .fieldset-date {
    padding-right: 15px;
  }
  div.modal-date-review {
    padding-right: 28px;
  }
  .attribute-picklist-review {
    padding-right: 30px;
  }
  button.modal-cancel,
  button.modal-save,
  button.modal-create-approve {
    line-height: 1;
    width: 60px;
    height: 35px;
    padding-left: 6px;
    padding-right: 6px;
  }
  button.modal-cancel,
  button.modal-save {
    font-size: 12px;
  }
  button.modal-create-approve {
    font-size: 10px;
    width: 110px;
    white-space: normal;
  }
  .datepicker .btn-default {
    padding: 3px 5px;
  }
  .quarters-list {
    left: 188px;
  }
  .quarters-list li a {
    padding: 1.2px 10px;
  }
  .objectives-sub-table > tbody > tr > td {
    border-bottom: 1px solid #3A434E !important;
  }
  .currency-amount,
  .currency-percentage {
    margin-right: 8px;
  }
  .currency-amount {
    width: 30%;
  }
  .currency-percentage {
    margin-left: 8px;
    width: 20%;
  }
  .width-fieldset {
    width: 100%;
    float: none;
  }
  .currency-amount {
    margin-left: 0;
  }
  .contact-show-hide img.contact-shown {
    border-bottom: 4px solid #ffffff;
  }
  .title-in-detail {
    margin-top: -40px;
  }
  .slider-bar {
    margin-top: 15px;
    margin-left: -15px;
    padding-right: 0 !important;
  }
  .slider-bar span.left {
    margin-right: 1%;
  }
  .slider-bar span.right {
    margin-left: 1%;
  }
  input[type="range"] {
    width: 75%;
  }
  .btn-stacked {
    width: 100%;
    margin-bottom: 5px;
  }
  #process-views .btn {
    line-height: 1.8;
  }
  .training-header-buttons.btn-group {
    clear: both !important;
    float: none !important;
    margin-left: -15px;
    margin-top: 20px;
  }
  .training-header-buttons.btn-group > .btn {
    clear: both !important;
    float: none !important;
  }
}
@media (max-width: 670px) {
  /*only visible on xs, wider than 768px to allow for vertical scrollbar on some devices */
  div#client-logo-mobile {
    width: 90%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  .modal-dialog {
    width: 300px;
  }
  .modal-label-border {
    width: 298px;
  }
  .label.long-label {
    font-size: 12px;
    padding-right: 5px;
    padding-left: 5px;
  }
  .dependants .label.long-label {
    font-size: 12px;
    display: inline-block;
    line-height: 20px;
    white-space: normal;
  }
}
@media (max-width: 550px) {
  div#client-logo-mobile {
    width: 88%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
}
@media (max-width: 500px) {
  div#client-logo-mobile {
    width: 86%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  #sub-section {
    padding-left: 15px !important;
  }
  #sub-section .panel .panel-body {
    margin-top: 0px !important;
  }
  #sub-section .panel .panel-body .h3 {
    margin-bottom: 30px;
  }
  #sub-section .panel > .panel-collapse .panel-body {
    border-top-color: #ddd;
    background-color: transparent;
    margin-top: 0;
    padding-top: 0;
    /* padding-left: 37px; */
    /* padding-right: 37px; */
    padding-bottom: 0px;
    /* border-right-color: rgb(221, 221, 221); */
    /* border-right-style: solid; */
    border-right-width: 1px;
    /* border-left-color: rgb(221, 221, 221); */
    /* border-left-style: solid; */
    border-left-width: 1px;
    border-bottom-color: #dddddd;
    border-bottom-style: solid;
    border-bottom-width: 3px;
  }
  .view-details-section-open {
    padding-top: 15px;
    padding-right: 20px;
    padding-bottom: 23px;
    padding-left: 20px;
  }
  .view-details-section {
    padding-top: 15px;
    padding-right: 20px;
    padding-bottom: 23px;
    padding-left: 20px;
  }
  .objectives-panel-body {
    padding-top: 0px;
  }
  #context_div {
    height: 80px;
  }
  .img-container {
    height: 80px;
  }
  .userProfileImg {
    margin-top: -2px;
    width: 86px;
    height: 86px;
  }
  .other-properties {
    padding-top: 15px;
    padding-right: 15px;
    padding-bottom: 5px;
    padding-left: 15px;
    margin-right: 0px !important;
    margin-left: 0px !important;
  }
  .profile-contact {
    margin-top: 2%;
  }
}
@media (max-width: 450px) {
  div#client-logo-mobile {
    width: 83%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  div#client-logo-mobile > img {
    margin-left: 37%;
    margin-left: calc(21.5%);
    margin-left: -webkit-calc(21.5%);
    margin-left: -moz-calc(21.5%);
  }
}
@media (max-width: 400px) {
  div#client-logo-mobile {
    width: 80%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
}
@media (max-width: 350px) {
  div#client-logo-mobile {
    width: 75%;
    width: calc(60%);
    width: -webkit-calc(60%);
    width: -moz-calc(60%);
  }
  div#client-logo-mobile > img {
    margin-left: 35%;
    margin-left: calc(21.5%);
    margin-left: -webkit-calc(21.5%);
    margin-left: -moz-calc(21.5%);
  }
}
@media (min-width: 980px) {
  .userProfileImg {
    margin-left: 16px;
  }
  #sub-section {
    padding-left: 15px !important;
    padding-right: 0px;
  }
  #sub-section .panel > .panel-collapse .panel-body {
    border-top-color: #ddd;
    background-color: #E9EDEF;
    margin-top: 0;
    padding-top: 0;
    padding-left: 37px;
    padding-right: 37px;
    padding-bottom: 25px;
    border-right-color: #dddddd;
    border-right-style: solid;
    border-right-width: 1px;
    border-left-color: #dddddd;
    border-left-style: solid;
    border-left-width: 1px;
  }
}
@media (min-width: 1920px) {
  .userProfileImg {
    margin-left: 22px;
  }
  #sub-section {
    padding-left: 30px !important;
  }
}
@media (min-width: 1280px) {
  .userProfileImg {
    /*margin-left: 22px;*/
  }
  #sub-section {
    padding-left: 30px !important;
    padding-right: 15px;
  }
}
/* END OF MEDIA QUERIES */
/* display mode detection */
.display-mode {
  height: 0;
  margin: 0;
  overflow: hidden;
  padding: 0;
}
.display-mode span {
  display: inline-block;
  height: 1px;
  width: 1px;
}
@media only screen and (max-width: 775px) {
  #sub-section {
    margin-top: 60px;
  }
}
@media only screen and (max-width: 767px) {
  .display-mode .tablet,
  .display-mode .tablet-landscape,
  .display-mode .laptop,
  .display-mode .desktop {
    display: none;
  }
  .team-accordion-border {
    font-size: 14px !important;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
    line-height: 0.8;
    font-size: 13px;
    padding-bottom: 0px;
    border-bottom: none !important;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body h4 {
    margin: 0px 0 0px;
  }
  #sub-section .panel .panel-body .h3 {
    margin-top: 0px ;
    margin-bottom: 0px;
  }
  #footer {
    margin-bottom: 50px;
  }
  .other-properties {
    padding-top: 15px;
    /* padding-right: 5px; */
    padding-bottom: 5px;
    /* padding-left: 5px; */
    margin-right: -15px;
    margin-left: -15px;
  }
  .other-milestones {
    padding-right: 15px;
    padding-left: 15px;
    padding-bottom: 0;
    margin-bottom: 0 !important;
  }
  .other-milestones > .col-lg-6 {
    padding-right: 0px;
    padding-left: 0px;
  }
  .fairsail-background {
    padding-top: 20px;
  }
  .view-details-section-open {
    /*padding-top: 15px;*/
    /*padding-right: 20px;*/
    /*padding-bottom: 23px;*/
    /*padding-left: 20px;*/
  }
  .view-details-section {
    /*padding-top: 15px;*/
    /*padding-right: 20px;*/
    /*padding-bottom: 23px;*/
    /*padding-left: 20px;*/
  }
  div.list-group-item-text {
    border: 1px solid #ddd;
    padding: 10px;
    margin-right: 15px;
    margin-left: 15px;
  }
  div.list-group-item-text:first-child {
    border-bottom: none;
  }
  div.list-group-item-text .row {
    margin-top: 0 !important;
    margin-bottom: 0 !important;
  }
  .view-details-btn-close {
    border-bottom: solid 1px #ddd;
    margin-bottom: -6px;
  }
  .view-details-btn-open {
    border-bottom: solid 1px #FFF;
    margin-bottom: -6px;
  }
  div.accordian-spacer {
    margin-bottom: 0px !important;
  }
  #sub-section .panel .headerrow {
    margin-top: 0px;
    margin-bottom: 0px;
  }
  .objectives-table {
    margin-top: 0px !important;
  }
  #sub-section .team-accordion .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
    line-height: 0.8;
    font-size: 13px;
    padding-bottom: 0px;
    border-bottom: none !important;
  }
  #sub-section .panel > .panel-collapse .panel-body h4 {
    margin: 15px 0 0px;
  }
  div.list-group-item-text .btn {
    text-align: left;
  }
  #sub-section .panel > .panel-collapse {
    margin-bottom: 12px !important;
    margin-right: 0px;
  }
  div.mobileSpacer {
    margin-bottom: 0px !important;
    margin-top: 0px !important;
  }
  #sub-section .panel > .panel-collapse .panel-body {
    padding-top: 0;
    border: none;
  }
  .objectives-panel-body {
    padding-top: 10px;
  }
  .img-container {
    height: 80px;
  }
  div.h3 {
    margin-top: 0px !important;
  }
}
@media only screen and (min-width: 500px) and (max-width: 767px) {
  .userProfileImg {
    margin-top: -7px;
    width: 86px;
    height: 86px;
  }
  .img-container {
    height: 68px;
  }
  .other-properties {
    padding-top: 15px;
    padding-right: 15px;
    padding-bottom: 5px;
    padding-left: 15px;
    margin-right: 0px !important;
    margin-left: 0px !important;
  }
  .panel-body .other-properties:last-of-type {
    border-bottom: solid 5px #ddd !important;
  }
}
@media only screen and (min-width: 767px) and (max-width: 991px) {
  .display-mode .mobile,
  .display-mode .tablet-landscape,
  .display-mode .laptop,
  .display-mode .desktop {
    display: none;
  }
  .view-details-section {
    margin-right: 0px;
  }
  #sub-section .panel > .panel-collapse .panel-body {
    border-top-color: #ddd;
    background-color: #E9EDEF;
    margin-top: 0;
    padding-top: 0;
    padding-left: 37px;
    padding-right: 37px;
    padding-bottom: 25px;
    border-right-color: #dddddd;
    border-right-style: solid;
    border-right-width: 1px;
    border-left-color: #dddddd;
    border-left-style: solid;
    border-left-width: 1px;
  }
}
@media only screen and (min-width: 992px) and (max-width: 1199px) {
  .display-mode .mobile,
  .display-mode .tablet,
  .display-mode .laptop,
  .display-mode .desktop {
    display: none;
  }
  .view-details-section {
    margin-right: 1px;
  }
}
@media (min-width: 1200px) and (max-width: 1599px) {
  .display-mode .mobile,
  .display-mode .tablet,
  .display-mode .tablet-landscape,
  .display-mode .desktop {
    display: none;
  }
  .view-details-section {
    margin-right: 0px;
  }
}
@media (min-width: 1600px) {
  .display-mode .mobile,
  .display-mode .tablet,
  .display-mode .tablet-landscape,
  .display-mode .laptop {
    display: none;
  }
  .view-details-section {
    margin-right: 0px;
  }
}
table.details-table {
  empty-cells: show;
  max-width: 100%;
  width: 100%;
}
.details-table {
  border-collapse: collapse;
  width: 100%;
}
/* Structure */
.details-table {
  border: 0;
  padding: 0;
}
.details-table th,
.details-table td {
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  /* padding: .5em .7em; */
}
.details-table tr th,
.details-table tr td {
  font-size: 13px;
  border-right: solid 1px #4D555C;
  padding: 8px;
  line-height: 1.42857143;
  vertical-align: top;
  font-weight: normal;
}
.details-table tr th {
  text-transform: uppercase;
  background-color: #3A434E;
  color: #fff;
}
.details-table tr td {
  background-color: #ffffff;
  color: #78858e;
  border: 1px solid #3A434E;
}
th.blank-row {
  background-color: #ffffff !important;
  border-right: 1px solid #ffffff !important;
}
/* Table rows have a gray bottom stroke by default */
.details-table-stack tbody tr {
  border-bottom: none;
}
.details-table-stack td .details-table-cell-label,
.details-table-stack th .details-table-cell-label {
  display: none;
}
/* progress bar override */
.progress-bar {
  font-size: 6px;
  line-height: 10px;
}
/* Mobile first styles: Begin with the stacked presentation at narrow widths */
@media only all {
  /*     Show the table cells as a block level element */
  .details-table-stack td,
  .details-table-stack th {
    text-align: left;
    display: block;
  }
  .details-table-stack tr {
    clear: both;
    display: table-row;
  }
  /*     Make the label elements a percentage width */
  .objectives-table-stack td .objectives-table-cell-label,
  .objectives-table-stack th .objectives-table-cell-label {
    display: block;
    padding: 10px;
    min-width: 45%;
    display: inline-block;
    background-color: #3A434E;
    color: #fff;
    font-weight: normal;
    font-size: 13px;
    text-transform: uppercase;
    margin-right: 15px;
  }
  /* For grouped headers, have a different style to visually separate the levels by classing the first label in each col group */
  .objectives-table-stack th .objectives-table-cell-label-top,
  .objectives-table-stack td .objectives-table-cell-label-top {
    display: block;
    padding: .4em 0;
    margin: .4em 0;
  }
  .details-table-cell-label {
    display: block;
  }
  /* Avoid double strokes when stacked */
  .details-table-stack tbody th.group {
    margin-top: -1px;
  }
  /* Avoid double strokes when stacked */
  .details-table-stack th.group b.details-table-cell-label {
    display: none !important;
  }
}
@media (max-width: 39.9375em) {
  .details-table-stack thead td,
  .details-table-stack thead th {
    display: none;
  }
  .details-table-stack tbody td,
  .details-table-stack tbody th {
    clear: left;
    float: left;
    width: 100%;
    font-weight: normal;
    font-size: 14px;
    border-bottom: solid 1px #ddd;
    border-right: solid 1px #ddd;
  }
  /*    .objectives-sub-table > tbody > tr > td:first-child {
          border-top: 1px solid #ddd !important;
      }*/
  .view-details-btn-plus {
    border-right: 1px solid #DDD;
    border-color: #DDD;
    border-style: solid;
    border-width: 1px;
    line-height: 1.33;
    background-color: #FFF;
    padding-top: 4px;
    padding-right: 7px;
    padding-bottom: 5px;
    padding-left: 7px;
    color: #333;
    font-weight: normal;
    text-align: center;
    font-size: 11px;
    white-space: nowrap;
    vertical-align: bottom;
    cursor: pointer;
    height: 29px !important;
    width: 115px !important;
  }
  .view-details-btn-close {
    vertical-align: bottom;
    padding-top: 7px;
    padding-right: 10px;
    padding-bottom: 7px;
    padding-left: 10px;
  }
  .view-details-btn-open {
    vertical-align: bottom;
    padding-top: 12px;
    padding-right: 10px;
    padding-bottom: 10px;
    padding-left: 10px;
  }
  .button {
    padding: 8px 12px 8px 12px;
    font-size: 13px;
  }
  .btn {
    font-size: 12px;
  }
  #menu-right .btn {
    font-size: 14px;
    /* to align with rest of search bar */
  }
}
/* Media query to show as a standard table at 560px (35em x 16px) or wider */
@media (min-width: 40em) {
  #sub-section .panel .panel-body .h3Text {
    margin-top: 20px;
    margin-bottom: 0px;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body h4 {
    margin: 0px 0 0px;
  }
  #sub-section .team-accordion .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
    line-height: 0.8;
    font-size: 13px;
    padding-bottom: 0px;
    border-bottom: none !important;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
    line-height: 0.8;
    font-size: 13px;
    border-bottom: none !important;
  }
  .team-accordion-border {
    font-size: 14px !important;
  }
  div.list-group-item-text .btn {
    text-align: left;
  }
  .details-table-stack tr {
    display: table-row;
  }
  /* Show the table header rows */
  .details-table-stack td,
  .details-table-stack th,
  .details-table-stack thead td,
  .details-table-stack thead th {
    display: table-cell;
    margin: 0;
    padding: 8px;
    line-height: 1.42857143;
    vertical-align: top;
    font-weight: normal;
    border-left: 1px solid #ddd;
    border-bottom: 1px solid #ddd;
    font-size: 14px;
    border-right: solid 1px #ddd;
  }
  /* Hide the labels in each cell */
  .details-table-stack td .details-table-cell-label,
  .details-table-stack th .details-table-cell-label {
    display: none !important;
  }
}
@media (max-width: 39em) {
  #sub-section .panel .panel-body .h3Text {
    margin-top: 20px;
    margin-bottom: 0px;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body .other-properties h4.panel-title {
    line-height: 0.8;
    font-size: 13px;
    padding-bottom: 0px;
    border-bottom: none !important;
  }
  #sub-section .team-accordion-mobile .panel > .panel-collapse .panel-body h4 {
    margin: 0px 0 0px;
  }
  div.list-group-item-text .btn {
    text-align: left;
  }
  .pdf-open {
    padding-bottom: 15px;
    margin-left: 15px;
    margin-top: 0px;
  }
  .pdf-close {
    padding-bottom: 15px;
    margin-left: 15px;
    margin-top: -8px;
  }
}
@media only screen and (min-width: 625px) and (max-width: 768px) {
  .pdf-open {
    padding-bottom: 15px;
    margin-left: 15px;
    margin-top: 0px;
  }
  .pdf-close {
    padding-bottom: 15px;
    margin-left: 15px;
    margin-top: -8px;
  }
}
.component {
  /* line-height: 1.5em; */
  /* margin: 0 16px; */
  /* padding: 0px 0 2px; */
  /* width: 90%; */
  max-width: 1074px;
  /*max-height: 606px;*/
  overflow-x: hidden;
  padding-left: 9px;
  padding-right: 7px;
  /* margin: 0; */
}
.component .filler {
  font-family: "Blokk", Arial, sans-serif;
  color: #d3d3d3;
}
.resetme {
  padding-left: 0;
}
.resetme li:first-child {
  padding-left: 30px;
  color: #00529f;
}
.treeview-cell li:first-child {
  width: 30.285%;
  color: #00529f;
}
.treeview-main {
  margin: 0;
  padding: 0;
  width: 100%;
  text-align: left;
  font-size: 12px;
  background-color: #fff;
  min-width: 1488px;
}
.treeview-cell {
  overflow: hidden;
  margin: 0;
  padding: 0;
}
.treeview-cell li {
  display: block;
  float: left;
  border: 1px solid #DCDCDC;
  border-width: 0 1px 1px 0;
  width: 11.618%;
  padding: 0.5% 12px 0.5% 12px;
  box-sizing: border-box;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
  max-height: 100px;
  transition: .8s;
  overflow: hidden;
}
.treeview-cell li:nth-child(7n+0) {
  border-right: 1px solid #DCDCDC;
}
.treeview-cell li:nth-child(1),
.treeview-cell li:nth-child(8),
.treeview-cell li:nth-child(15),
.treeview-cell li:nth-child(22),
.treeview-cell li:nth-child(29),
.treeview-cell li:nth-child(36) {
  border-left: 1px solid #DCDCDC;
}
.treeview-cell .treeview-enabled {
  font-size: 12px;
  color: #666666;
}
.treeview-cell .treeview-fields {
  background-color: #FCB05F;
  color: white !important;
}
.treeview-cell .treeview-head {
  border-top: 1px solid #DCDCDC;
  background: #3A434E;
  color: #fff;
  text-transform: uppercase;
}
.treeview-cell .treeview-head:nth-child(1),
.treeview-cell .treeview-head:nth-child(7) {
  background: #3A434E;
}
.carousel-control.right {
  right: 15px;
  left: auto;
  background-image: none;
  background-color: #005aae;
  padding-left: 36px;
  cursor: pointer;
}
.carousel-control.left {
  background-image: none;
  background-color: #005aae;
  padding-left: 36px;
  cursor: pointer;
}
.inActive {
  /* cursor: pointer; */
  /* display: none; */
  cursor: none;
  background-color: #D9DADA !important;
}
.carousel-control {
  position: absolute;
  margin-top: 1px;
  top: 0;
  bottom: 0;
  left: 15px;
  width: 3%;
  font-size: 20px;
  color: #fff;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
  filter: alpha(opacity=50);
  opacity: 1.5;
}
.carousel-control .glyphicon-chevron-left,
.carousel-control .glyphicon-chevron-right,
.carousel-control .icon-prev,
.carousel-control .icon-next {
  width: 30px;
  height: 30px;
  margin-top: -15px;
  margin-left: -15px;
  font-size: 18px;
}
.carousel-control .icon-next,
.carousel-control .glyphicon-chevron-right {
  right: 15%;
}
.carousel-control .icon-prev,
.carousel-control .icon-next,
.carousel-control .glyphicon-chevron-left,
.carousel-control .glyphicon-chevron-right {
  position: absolute;
  top: 50%;
  z-index: 5;
  display: inline-block;
}
.treeview-scroll-bars {
  padding-left: 35px;
  padding-right: 35px;
}
#treeview-tabs {
  padding-top: 1px;
  margin-left: -15px;
  margin-right: -15px;
  padding-left: 15px;
  padding-right: 15px;
  margin-top: 0px;
  min-width: 4488px;
}
/*#treeview-tabs > ul {*/
/*padding: 0;*/
/*margin: 0;*/
/*list-style-type: none;*/
/*text-align: left;*/
/*}*/
#treeview-tabs ul {
  padding: 0;
  margin: 0;
  list-style-type: none;
  text-align: left;
}
/*#treeview-tabs > ul > li {*/
/*border-right: solid 1px #4D555C;*/
/*background-color: #3A434E;*/
/*padding-top: 12px;*/
/*padding-right: 13px;*/
/*padding-bottom: 12px;*/
/*padding-left: 13px;*/
/*font-size: 14px;*/
/*text-align: left;*/
/*text-transform: uppercase;*/
/*font-weight: normal;*/
/*color: #fff;*/
/*white-space: nowrap;*/
/*vertical-align: baseline;*/
/*border-radius: 0px !important;*/
/*cursor: pointer;*/
/*display: table-cell;*/
/*width: 1%;*/
/*}*/
#treeview-tabs li {
  border-right: solid 1px #DCDCDC;
  background-color: #3A434E;
  padding-top: 8px;
  /*padding-right: 13px;*/
  padding-bottom: 8px;
  padding-left: 13px;
  font-size: 11px;
  text-align: left;
  text-transform: uppercase;
  font-weight: normal;
  color: #fff;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0px !important;
  /*cursor: pointer;*/
  display: table-cell;
  width: 1%;
}
/*#treeview-tabs > ul > span > li.field {*/
/*background-color: #FFF;*/
/*color: #666666;*/
/*text-transform: none;*/
/*}*/
#treeview-tabs li.field {
  background-color: #FFF;
  color: #666666;
  text-transform: none;
}
#treeview-tabs li:nth-child(1) {
  border-left: solid 1px #DCDCDC;
  color: #00529f;
  position: absolute;
  width: 130px !important;
}
#treeview-tabs li:nth-child(2) {
  border-left: solid 1px #DCDCDC;
  color: #00529f;
}
#treeview-tabs li {
  width: 15%;
}
#treeview-tabs ul:nth-child(1) {
  border-bottom: none !important;
}
#treeview-tabs ul li {
  border-bottom: solid 1px #DCDCDC;
  display: inline-block;
  max-width: 130px;
  /* 'X' minus gutter */
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}
#treeview-tabs ul.resetme {
  padding-left: 0;
}
#treeview-tabs ul.resetme li:first-child {
  padding-left: 30px;
  color: #00529f;
}
.tile-btn:hover {
  background-color: #005aae;
  cursor: pointer;
}
.crop-image {
  display: block;
}
.alert-warning {
  color: #7e7e88;
  background-color: #FBFBFB;
  border: 1px solid #F1F1F1 !important;
  /* border-color: #faebcc; */
}
.alert {
  padding: 15px;
  margin-bottom: 7px;
  margin-top: 10px;
  border: 1px solid transparent;
  border-radius: 0px;
}
.toggle-off {
  display: none !important;
}
.toggle-on {
  display: block;
}
.toggle-main-on {
  width: 100% !important;
}
.toggle-btn {
  display: none;
}
.angucomplete-holder {
  position: relative;
}
.angucomplete-dropdown {
  border-color: #BFBFBF;
  border-width: 1px;
  border-style: solid;
  border-radius: 2px;
  width: 100%;
  padding: 6px;
  cursor: pointer;
  z-index: 9999;
  position: absolute;
  font-size: 12.5px;
  /*top: 32px;
  left: 0px;
  */
  margin-top: -1px;
  background-color: #ffffff;
}
.padded-row {
  margin-left: 15px;
  -webkit-margin-end: 14px;
  margin-right: 15px;
  padding: 10px 10px 10px 10px;
  background-color: #004586;
}
.angucomplete-searching {
  color: #acacac;
  font-size: 12.5px;
}
.angucomplete-description {
  font-size: 11px;
  margin-top: -3px;
}
.angucomplete-row {
  padding: 5px;
  color: #000000;
  margin-bottom: 4px;
  clear: both;
}
.angucomplete-selected-row {
  background-color: #001d39;
  color: #ffffff;
}
.angucomplete-image-holder {
  padding-top: 2px;
  float: left;
  margin-right: 10px;
  margin-left: 5px;
}
.angucomplete-image {
  height: 38px;
  width: 38px;
  border-radius: 50%;
  border-color: #ececec;
  border-style: solid;
  border-width: 1px;
}
.angucomplete-image-default {
  /* Add your own default image here
   background-image: url('/assets/default.png');
  */
  background-position: center;
  background-size: contain;
  height: 38px;
  width: 38px;
}
.highlight {
  color: #00529f;
}
@media print {
  .col-sm-1,
  .col-sm-2,
  .col-sm-3,
  .col-sm-4,
  .col-sm-5,
  .col-sm-6,
  .col-sm-7,
  .col-sm-8,
  .col-sm-9,
  .col-sm-10,
  .col-sm-11,
  .col-sm-12 {
    float: left;
  }
  .col-sm-12 {
    width: 100%;
  }
  .col-sm-11 {
    width: 91.66666667%;
  }
  .col-sm-10 {
    width: 83.33333333%;
  }
  .col-sm-9 {
    width: 75%;
  }
  .col-sm-8 {
    width: 66.66666667%;
  }
  .col-sm-7 {
    width: 58.33333333%;
  }
  .col-sm-6 {
    width: 50%;
  }
  .col-sm-5 {
    width: 41.66666667%;
  }
  .col-sm-4 {
    width: 33.33333333%;
  }
  .col-sm-3 {
    width: 25%;
  }
  .col-sm-2 {
    width: 16.66666667%;
  }
  .col-sm-1 {
    width: 8.33333333%;
  }
  .col-sm-pull-12 {
    right: 100%;
  }
  .col-sm-pull-11 {
    right: 91.66666667%;
  }
  .col-sm-pull-10 {
    right: 83.33333333%;
  }
  .col-sm-pull-9 {
    right: 75%;
  }
  .col-sm-pull-8 {
    right: 66.66666667%;
  }
  .col-sm-pull-7 {
    right: 58.33333333%;
  }
  .col-sm-pull-6 {
    right: 50%;
  }
  .col-sm-pull-5 {
    right: 41.66666667%;
  }
  .col-sm-pull-4 {
    right: 33.33333333%;
  }
  .col-sm-pull-3 {
    right: 25%;
  }
  .col-sm-pull-2 {
    right: 16.66666667%;
  }
  .col-sm-pull-1 {
    right: 8.33333333%;
  }
  .col-sm-pull-0 {
    right: auto;
  }
  .col-sm-push-12 {
    left: 100%;
  }
  .col-sm-push-11 {
    left: 91.66666667%;
  }
  .col-sm-push-10 {
    left: 83.33333333%;
  }
  .col-sm-push-9 {
    left: 75%;
  }
  .col-sm-push-8 {
    left: 66.66666667%;
  }
  .col-sm-push-7 {
    left: 58.33333333%;
  }
  .col-sm-push-6 {
    left: 50%;
  }
  .col-sm-push-5 {
    left: 41.66666667%;
  }
  .col-sm-push-4 {
    left: 33.33333333%;
  }
  .col-sm-push-3 {
    left: 25%;
  }
  .col-sm-push-2 {
    left: 16.66666667%;
  }
  .col-sm-push-1 {
    left: 8.33333333%;
  }
  .col-sm-push-0 {
    left: auto;
  }
  .col-sm-offset-12 {
    margin-left: 100%;
  }
  .col-sm-offset-11 {
    margin-left: 91.66666667%;
  }
  .col-sm-offset-10 {
    margin-left: 83.33333333%;
  }
  .col-sm-offset-9 {
    margin-left: 75%;
  }
  .col-sm-offset-8 {
    margin-left: 66.66666667%;
  }
  .col-sm-offset-7 {
    margin-left: 58.33333333%;
  }
  .col-sm-offset-6 {
    margin-left: 50%;
  }
  .col-sm-offset-5 {
    margin-left: 41.66666667%;
  }
  .col-sm-offset-4 {
    margin-left: 33.33333333%;
  }
  .col-sm-offset-3 {
    margin-left: 25%;
  }
  .col-sm-offset-2 {
    margin-left: 16.66666667%;
  }
  .col-sm-offset-1 {
    margin-left: 8.33333333%;
  }
  .col-sm-offset-0 {
    margin-left: 0%;
  }
  .visible-xs {
    display: none !important;
  }
  .hidden-xs {
    display: block !important;
  }
  table.hidden-xs {
    display: table;
  }
  tr.hidden-xs {
    display: table-row !important;
  }
  th.hidden-xs,
  td.hidden-xs {
    display: table-cell !important;
  }
  .hidden-xs.hidden-print {
    display: none !important;
  }
  .hidden-sm {
    display: none !important;
  }
  .visible-sm {
    display: block !important;
  }
  table.visible-sm {
    display: table;
  }
  tr.visible-sm {
    display: table-row !important;
  }
  th.visible-sm,
  td.visible-sm {
    display: table-cell !important;
  }
}
