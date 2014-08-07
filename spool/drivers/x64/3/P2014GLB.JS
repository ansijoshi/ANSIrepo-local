
// this function will patch a click method onto anchor elements for Mozilla. Due apparently to confusion in the early DOM spec, anchor elements in mozilla are missing click methods. This will attach a click method to HTMLElement so that all elements, being descendants of this object will inherit it if they dont have one of their own. 
if (!document.all) {
  try {
		document.createElement('a');
		HTMLElement.prototype.click = function () {
			if (typeof this.onclick == 'function') {
				if (this.onclick({type: 'click'}) && this.href) 
					window.open(this.href, this.target ? this.target : '_self');
			}
			else if (this.href)
				window.open(this.href, this.target ? this.target : '_self');
		}
	}
	catch (e) {
		window.status='Warning: your browser is unable to attach click methods to all elements.';
	}
}



// only for use with absolute positioned elements. 
function mouseIsOverAbsElement(obj) {
	if ((mouseX < obj.offsetLeft) || (mouseX > obj.offsetLeft + obj.offsetWidth)) return false;
	else if ((mouseY < obj.offsetTop) || (mouseY > obj.offsetTop + obj.offsetHeight)) return false;
	else return true;
}
function mouseTracker(e) {
	mouseX = (document.all) ? window.event.x : e.pageX;
	mouseY = (document.all) ? window.event.y : e.pageY;
}

window.onmousemove = mouseTracker;
var mouseX = 0;
var mouseY = 0;


function globalComponentInit() {
	if (typeof(ToolbarManager)!="undefined") {
		ourToolbarManager = new ToolbarManager();
		ourToolbarManager.init();
	}
	if (typeof(ButtonManager)!="undefined") {
		ourButtonManager = new ButtonManager();
		ourButtonManager.init();
	}
	if (typeof(TransferBoxManager)!="undefined") {
		ourTransferBoxManager = new TransferBoxManager();
		ourTransferBoxManager.init();
	}
	if (typeof(DropdownMenuManager)!="undefined") {
		ourDropdownMenuManager = new DropdownMenuManager();
		ourDropdownMenuManager.init();
		document.onmousedown= dropdownMenuManager_clearMenus;
	}
	if (typeof(NavigationControlManager)!="undefined") {
		ourNavigationControlManager = new NavigationControlManager();
		ourNavigationControlManager.init();
	}
	if (typeof(TabManager)!="undefined") {
		ourTabManager = new TabManager();
		ourTabManager.init();
	}
	if (typeof(TableManager)!="undefined") {
		ourTableManager = new TableManager();
		ourTableManager.init();
	
		
		tableManager_windowResize();
		// to disable the default behaviour that ctrl-clicks selects a whole word. 
		// Ctrl-click within hp applications has a special meaning. 
		if (document.all) {					
			document.onselectstart = function() {var ctrlKey = (document.all) ? window.event.ctrlKey :mozEvent.ctrlKey;if (ctrlKey)return false;}
		}
	}
	if (typeof(TreeManager)!="undefined") {
		ourTreeManager = new TreeManager();
		ourTreeManager.init();
	}
	if (typeof(TreeTableManager)!="undefined") {
		ourTreeTableManager = new TreeTableManager();
		ourTreeTableManager.init();
	}	
}
var ourToolbarManager = null;
var ourButtonManager = null;
var ourTransferBoxManager = null;
var ourDropdownMenuManager = null;
var ourNavigationControlManager = null;
var ourTabManager = null;
var ourTableManager = null;
var ourTreeManager = null;
var ourTreeTableManager = null;



function dF(foo) {
	document.debugform.debugtext.value += foo + "\n";
}

// a little global function that returns a reasonably cross-browser reference to the originating object of the given mozEvent. 
function getEventOriginator(mozEvent) {
	return (document.all) ?  event.srcElement : mozEvent.target;
}

// attaches event handlers that various components need, without destroying the application's own event handlers in the process.
function reconcileEventHandlers() {
	if (window.onload) {   // some onload code has been placed into the body tag, or some function assigned to window.onload, before this function was called.
		// capture it as a function object, assign it to a var. 
		var applicationLevelOnload = window.onload;  		
		// execute our globalComponentInit, then execute the function object holding the other onload code. 
		eval("window.onload = function() {globalComponentInit();var applicationLevelOnload="+applicationLevelOnload+";applicationLevelOnload()}");
	}
	else { // window.onload is still untouched when this function gets called. 
		window.onload = globalComponentInit;
	}

	if (typeof(TableManager)!="undefined") {
		
		if (window.onresize) {
			var applicationLevelOnresize = window.onresize;
			eval("window.onresize = function() {tableManager_windowResize();var applicationLevelOnresize="+applicationLevelOnresize+";applicationLevelOnresize();}");
		}
		else { // window.onload is still untouched when this function gets called. 
			window.onresize = tableManager_windowResize;
		}
	}
}
// some implementations where classNames need to be changed may have multiple class selectors in their classname.  This will add a classname as a class selector, if it is not already present, and without deleting other unrelated classnames that might be present. 
function appendClassName(obj, newClassName) {
	if (obj.className.indexOf(newClassName)!=-1){
		return true;
	}
	if (!obj.className){
		obj.className = newClassName;
	} else {
		obj.className = obj.className + " " + newClassName;
	}
}
function removeClassName(obj, classNameToRemove) {
	var newClassName = obj.className.replace(" "+classNameToRemove,"");
	newClassName = newClassName.replace(classNameToRemove+" ","");
	if (obj.className.length == newClassName.length) {
		newClassName = newClassName.replace(classNameToRemove,"");
	}
	obj.className = newClassName;
}


//tooltip
var offsetxpoint = 10; //Customize x offset of tooltip
var offsetypoint = 20; //Customize y offset of tooltip
var ie=document.all;
var ns6=document.getElementById && !document.all;
var enabletip=false;

function ietruebody(){
	if (document.documentElement && document.documentElement.clientHeight){
	// Explorer 6 Strict Mode{
		return document.documentElement;
	} else if (document.body){ // other Explorers
		return document.body;
	}


	return document.documentElement;
}

function showTip(thetext, thecolor, thewidth){
	var elm = document.getElementById("tooltip");
	if (typeof thewidth!="undefined") {
		elm.style.width=thewidth+"px";
	}
	if (typeof thecolor!="undefined" && thecolor!=""){
		elm.style.backgroundColor=thecolor;
	}
	elm.innerHTML=thetext;
	enabletip=true;
	return false;
}

function positiontip(e){
	var elm = document.getElementById("tooltip");
	if (enabletip){
		var curX=(ns6)?e.pageX : event.x+ietruebody().scrollLeft;
		var curY=(ns6)?e.pageY : event.y+ietruebody().scrollTop;
		
		var rightedge=ie? ietruebody().clientWidth-event.clientX-offsetxpoint : window.innerWidth-e.clientX-offsetxpoint-20;
		var bottomedge=ie? ietruebody().clientHeight-event.clientY-offsetypoint : window.innerHeight-e.clientY-offsetypoint-20;

		var leftedge=(offsetxpoint<0)? offsetxpoint*(-1) : -1000

		if (rightedge<elm.offsetWidth){
			elm.style.left=ie? ietruebody().scrollLeft+event.clientX-elm.offsetWidth+"px" : window.pageXOffset+e.clientX-elm.offsetWidth+"px";
		} else if (curX<leftedge){
			elm.style.left="-5px";
		} else {
			elm.style.left=curX+offsetxpoint+"px";
		}

		if (bottomedge<elm.offsetHeight){
			elm.style.top=ie? ietruebody().scrollTop+event.clientY-elm.offsetHeight-offsetypoint+"px" : window.pageYOffset+e.clientY-elm.offsetHeight-offsetypoint+"px";
		}else{
			elm.style.top=curY+offsetypoint+"px";
			elm.style.visibility="visible";
		}
	}
}

function hideTip(){
	var elm = document.getElementById("tooltip");
	enabletip=false;
	elm.style.visibility="hidden";
	elm.style.left="-1000px";
	elm.style.backgroundColor="";
	elm.style.width="";
}

document.onmousemove = positiontip;


/*******************
 * PLS FUNCTIONS   *
 *******************/

function WindowOpen(url){
window.open(url,'hpwindow','height=500,width=800,resizable=1,directions=1,location=1,toolbar=1,menubar=1,scrollbars=1');
}

