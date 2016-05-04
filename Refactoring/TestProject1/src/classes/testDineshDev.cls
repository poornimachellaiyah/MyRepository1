public with sharing class testDineshDev{

public string MyData {get;set;}

public testDineshDev() {
    MyData = '';    
}

public PageReference printView() {
    PageReference oPageRef = Page.MyPage2;
    oPageRef.setRedirect(false);

    return oPageRef;
}
}