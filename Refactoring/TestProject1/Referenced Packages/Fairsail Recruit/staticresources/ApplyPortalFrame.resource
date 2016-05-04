function FAPwriteFairsailApplicantPortal() {
	if (FAPchainOnload!=null) FAPchainOnload();
	var baseURL = FAPsrc.substring( 0, FAPsrc.indexOf("/resource/")+1); 
	var pdiv = document.getElementById('FairsailApplicantPortal');
	var sUrl = window.location.href;
	if (pdiv!=null) {
		// set up auto resize of iframe
		try {
			var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
			var eventer = window[eventMethod];
			var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
			eventer(messageEvent,function(e) {
				var pframe = document.getElementById('FairsailApplicantPortalIframe');
				if (pframe!=null) pframe.style.height = e.data + 'px';
			},false);
		} catch (err) {}
		
		var portal = String(candidatePortalName);
		if (portal==null || portal=="undefined") portal = "";
		var portalType = ((sUrl != null && sUrl != "" && sUrl.search(/fRecruit__Agency/) > 0) ? "Agency" : ((sUrl != null && sUrl != "" && sUrl.search(/fRecruit__Internal/) > 0) ? "Internal" : "Apply"));
		if (sUrl != null && sUrl != "" && sUrl.search(/\?/) != -1 && sUrl.search(/vacancyNo=/)>sUrl.search(/\?/)) {
			// add the page's parameters to the iframe's URL
			var sparms = sUrl.slice(sUrl.search(/\?/));
			if (portal!='') {
				if (sparms=='') sparms = '?'; else sparms += '&';
				sparms += 'portal='+portal;
			}
			pdiv.innerHTML = "<iframe scrolling='no' src='"+baseURL+"fRecruit__"+portalType+"Job"+sparms+"' style='width:100%; height:100%; border:0; overflow: hidden;' id='FairsailApplicantPortalIframe'/>";
		} else if (sUrl != null && sUrl != "" && sUrl.search(/\?/) != -1 && sUrl.search(/uid=/)>sUrl.search(/\?/)) {
			// add the page's parameters to the iframe's URL
			var sparms = sUrl.slice(sUrl.search(/\?/));
			if (portal!='') {
				if (sparms=='') sparms = '?'; else sparms += '&';
				sparms += 'portal='+portal;
			}
			pdiv.innerHTML = "<iframe scrolling='no' src='"+baseURL+"fRecruit__"+portalType+"MyApplication"+sparms+"' style='width:100%; height:100%; border:0; overflow: hidden;' id='FairsailApplicantPortalIframe'/>";
		} else {
			if (portal!='') {
				portal = '?portal='+portal;
			}
			pdiv.innerHTML = "<iframe scrolling='no' src='"+baseURL+"fRecruit__"+portalType+"JobList"+portal+"' style='width:100%; height:100%;border:0; overflow: hidden;' id='FairsailApplicantPortalIframe'/>";
		}
	}
}
var FAPscripts = document.getElementsByTagName("script");
var FAPsrc = FAPscripts[FAPscripts.length-1].src;
var FAPchainOnload = window.onload;
window.onload = FAPwriteFairsailApplicantPortal;
