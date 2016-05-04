@isTest
public class RedirectWithVariablesControllerTest {

    static testmethod void testRedirect(){
    Account acc = new Account();
    acc.Name = 'Redirect Test Account';
    Insert acc;
    
    Contact manager = new Contact();
    manager.FirstName = 'Test';
    manager.LastName = 'Manager';
    Insert manager;
    
    Pagereference testPage = Page.RedirectWithVariables;
    testPage.getParameters().put('object', 'Contact');
    testPage.getParameters().put('allowRTS', 'FALSE');
    testPage.getParameters().put('ReportsTo', manager.name);
    testPage.getParameters().put('ID_ReportsTo', manager.id);
    testPage.getParameters().put('Account', acc.name);
    testPage.getParameters().put('ID_Account', acc.id);
    
    
     Test.setCurrentPageReference(testPage);
        System.debug('testPage:'+ testPage);
        RedirectWithVariablesController control = new RedirectWithVariablesController();
        Pagereference resultPage = control.redirectUser();
        System.debug('resultPage:'+ resultPage);
        System.assert(resultPage.getUrl().contains('/003/'));
        
        testPage.getParameters().put('allowRTS', 'TRUE');
        resultPage = control.redirectUser();
        System.debug('New testPage:'+ testPage);
        System.debug('New resultPage:'+ resultPage);
        
    }

}