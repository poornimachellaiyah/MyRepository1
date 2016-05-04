// Fairsail User Interface Client Script
// Copyright Fairsail 2008

var selfColor='#FF9900';
var managerColor='#2288ee';
var mentorColor='#228800';
var directReportColor='#663399';
var colleagueColor='#339966';
var customerColor='#999933';
var otherColor='#993333';
var averageColor='#3B5998';
var colors = new Object();
colors["Self"] = selfColor;
colors["Manager"] = managerColor;
colors["Mentor"] = mentorColor;
colors["Direct Report"] = directReportColor;
colors["Colleague"] = colleagueColor;
colors["Customer"] = customerColor;
colors["Other"] = otherColor;

function FormatPercent( value )
{
	if (String(value)!="undefined" && value!=null && value!="")
	{
		if (value > 0)
			document.write(Math.round(value)+"%");
	}
} 

function PercentageIndicator( current, total )
{
	var percentage = (current-1)/(total-1)*100;
	document.write('<div style="clear:none;float:left;">0%</div><div style="clear:none;float:left;height:10px;margin-top:3px;width:'+String(percentage)+'px;background-color:#3B5998;">&nbsp;</div><div style="clear:none;float:left;height:10px;margin-top:3px;width:'+String(100-percentage)+'px;background-color:#e0e0e0;">&nbsp;</div><div style="clear:none;float:left;width:50px">100%</div>');
}


function Bar( score, maximum, color )
{
	if (trim(score).length>0)
	{
		var percentage = (Number(score)-1)/(Number(maximum)-1)*100;
		if (percentage>100) percentage=100;
		document.write('<div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round(percentage*1.8))+'px;background-color:'+color+';">&nbsp;</div><div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round((100-percentage)*1.8))+'px;background-color:#e0e0e0;">&nbsp;</div><br/>');
	}
}

function NeedBar( score, need, maximum )
{
	if (trim(score).length>0)
	{
		var nscore = Number(score)-1;
		var nneed = Number(need)-1;
		var nmax = Number(maximum)-1;
		if (nneed>nscore)
			document.write('<div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round(nscore/nmax*180))+'px;background-color:#3B5998;">&nbsp;</div><div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round((nneed-nscore)/nmax*180))+'px;background-color:red;">&nbsp;</div><div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round((nmax-nneed)/nmax*180))+'px;background-color:#e0e0e0;">&nbsp;</div><br/>');
		else
			document.write('<div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round(nneed/nmax*180))+'px;background-color:#3B5998;">&nbsp;</div><div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round((nscore-nneed)/nmax*180))+'px;background-color:green;">&nbsp;</div><div style="clear:none;float:left;height:5px;margin-top:2px;font-size:1px;width:'+String(Math.round((nmax-nscore)/nmax*180))+'px;background-color:#e0e0e0;">&nbsp;</div><br/>');
	}
}

function getElementsByNameAndId(name,id)
{
	var result = new Array();
	var allPageTags=document.getElementsByTagName(name);
	for (i=0; i<allPageTags.length; i++) {
		if (allPageTags[i].id.indexOf(id)>=0) {
			result[result.length]=allPageTags[i];
		} 
	}
	return result;
}


function enable(id) {elementSet(id,false);}
function disable(id) {elementSet(id,true);}
function elementSet(id,value) {
	var elements = getElementsByNameAndId("input",id);
	for (var i=0; i<elements.length; i++)
		elements[i].disabled=value;
	var elements = getElementsByNameAndId("textarea",id);
	for (var i=0; i<elements.length; i++)
		elements[i].disabled=value;
}

function enableElements(id,item) {elementSetBelow(id,item,true);elementSetAbove(id,item-1,false);}
function elementSetAbove(id,item,value) {
	var elements = getElementsByNameAndId("input",id);
	for (var i=0; i<elements.length; i++)
	{
		var ending = elements[i].id.substring(elements[i].id.lastIndexOf(":")+1);
		if (Number(ending) > item) {
			elements[i].disabled=value;
			if (value) elements[i].checked = false;
		}
	}
}
function elementSetBelow(id,item,value) {
	var elements = getElementsByNameAndId("input",id);
	for (var i=0; i<elements.length; i++)
	{
		var ending = elements[i].id.substring(elements[i].id.lastIndexOf(":")+1);
		if (Number(ending) < item) {
			elements[i].disabled=value;
			if (value) elements[i].checked = false;
		}
	}
}

function dropMenu(name)
{
	currentMenu = '';
	var elements = getElementsByNameAndId('div',':'+name);
	for (var i=0; i<elements.length; i++)
			elements[i].style.display = 'none';
//	resetZ();
}
var currentMenu = '';
function popupMenu(name)
{
	if (currentMenu == name)
	{
		dropMenu(name);
	} else {
		if (currentMenu != '') 
			dropMenu(currentMenu);
		var elements = getElementsByNameAndId('div',':'+name);
//		setZ(document.getElementsByTagName('body')[0],1);
		for (var i=0; i<elements.length; i++)
		{
			elements[i].style.display = 'block';
//			elements[i].style.zIndex = 2;
		}
		currentMenu = name;
	}
}
var oldZs = null;
var oldElements = null;
function setZ(element, z)
{
	oldZs = new Array();
	oldElements = new Array();
	var i=0;
	if (element.nodeType==1 && (element.style.position == "relative" || element.style.position == "absolute"))
	{
		oldElements[i] = element;
		oldZs[i++] = element.style.zIndex;
		element.style.zIndex = z;
	}
	if (element.firstChild != null)
		setZ(element.firstChild,z);
	if (element.nextSibling != null)
		setZ(element.nextSibling,z);
}
function resetZ()
{
	if (oldElements != null)
		for (var i=0; i<oldElements.length; i++)
			oldElements[i].style.zIndex = oldZs[i];
	oldElements = null;
}
var doTwinToggle = true;
function cancelTwinToggle() {
	doTwinToggle = false;
}
function toggleNext( current )
{
	if (doTwinToggle) {
		current.style.display = 'none';
		if (current.nextSibling == null) {
			current.parentNode.nextSibling.firstChild.style.display = 'block';
		} else {
			current.nextSibling.style.display = 'block';
		}
	}
}				
function togglePrevious( current )
{
	if (doTwinToggle) {
		current.style.display = 'none';
		if (current.previousSibling == null) {
			current.parentNode.previousSibling.firstChild.style.display = 'block';
		} else {
			current.previousSibling.style.display = 'block';
		}
	}
}				
