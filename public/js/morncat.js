let bodyid = document.body.id;
let bodyObj = {
mjsimple: function(){return true},
//mjsimple: function(){ showNavig() },
mjsimple_v: function(){ showNavigV() }  
}
//bodyObj[bodyid]();

/////////////////////////////////////////////////////////////
let iconV = document.querySelector('.top_panel a.icon');
//alert(iconV.className);
if(iconV){
    iconV.addEventListener('click', showNavigV);
}
/////////////////////////////////////////////////////////////

function menuAlter(){
let w = window.innerWidth;
  if( w <= 768 && document.getElementById("alternav") ){
  document.getElementById("alternav").classList.remove("view");
  }
}

function delAlternav() {
//resizingWindow();
let elemId = [];
let classCollect = document.getElementsByClassName('dropdown-content');
  let i;
  for (i = 0; i < classCollect.length; i++) {
    elemId[i] = classCollect[i].id;
    let myDropdown = document.getElementById(elemId[i]);
    if (myDropdown.classList.contains('show')) {
      myDropdown.classList.remove('show');
    }
  }
/*let w = window.innerWidth;
console.log('w = ' + w);
  if( w <= 768 && document.getElementById("alternav") ){
  document.getElementById("alternav").classList.remove("view");
  }
*/
}

//document.addEventListener('resize', delAlternav);

//////////////////////////////////////////////
/* When the user clicks on the button, 
toggle between hiding and showing the dropdown content */
function showDropdown(dropdownId) {
  let elemId = [];
  let currId = document.getElementById(dropdownId);
  currId.classList.toggle("show");
  let classCollect = document.getElementsByClassName('dropdown-content');
  let i;
  for (i = 0; i < classCollect.length; i++) {
    elemId[i] = classCollect[i].id;
    if( elemId[i] != dropdownId ){
      document.getElementById(elemId[i]).classList.remove('show');
    }
  }

// Close the dropdown if the user clicks outside of it
window.onclick = function(e) {
  if (!e.target.matches('.dropbtn')) {
  let myDropdown = document.getElementById(dropdownId);
    if (myDropdown.classList.contains('show')) {
      myDropdown.classList.remove('show');
    }
  }
}
}

function showNavig() { //********************************
  //resizingWindow();
  window.addEventListener('resize', menuAlter);
  let w = window.innerWidth;
  //console.log('w = ' + w);
  if( w > 768 ){
    document.getElementById("alternav").classList.toggle("view");
  }else{
  document.getElementById("alternav").classList.remove("view");
  let x = document.getElementById("myTopnav");
  if (x.className === "nav_horbar") {
    x.className += " responsive";
  } else {
    x.className = "nav_horbar";
  }
  }
}//******************************************

///////////////////////////////////////////////
function resizeWindw(){
window.addEventListener('resize', go);
//go();
function go(){
  let widthWindow = window.innerWidth;
  if( widthWindow > 768 ){
    document.getElementById("altermenu").classList.remove("view_v");
    let searchForm = document.getElementById("searchFrm").firstElementChild;
    //alert(searchForm);
    let suchen = document.querySelector(".search_containr");
    //alert(suchen);
    if(searchForm != null){
      suchen.append(searchForm);
    }
    }
    //alert(this.event);
    if( widthWindow <= 768 && this.event != undefined ){
    let suchen = document.querySelector(".search_containr").firstElementChild;
    //alert('suchen = ' + suchen);
    let searchForm = document.getElementById("searchFrm");
    if(suchen != null){
      searchForm.append(suchen);
    }
    //alert(suchen.innerHTML);
    }
//}
    
let rightSide = document.querySelector('.right_container');
if(rightSide && document.getElementById('articl_box')){
let imgLogo = document.querySelector('#imgLogo');
//alert('imgLogo = ' + imgLogo);
let logoHeight = '0px';
if(imgLogo != null){
  logoHeight = getComputedStyle(imgLogo).height;
}
//alert(imgLogo);
//alert(document.getElementById('articl_box').getBoundingClientRect().height);
//alert(document.getElementById('articl_box').clientHeight);
//let logoHeight = getComputedStyle(imgLogo).height;
//alert(rightSide.clientHeight + ' ' + logoHeight);
let diff = rightSide.clientHeight + 30 - (document.getElementById('articl_box').clientHeight + +logoHeight.slice(0, logoHeight.length - 2));
//let diff = rightSide.clientHeight + 30 - (document.getElementById('articl_box').getBoundingClientRect().height + +logoHeight.slice(0, logoHeight.length - 2));
//elem.getBoundingClientRect()
//alert(diff);
if( diff > 0 && window.innerWidth >= 767 ){
document.getElementById('articl_box').style.height = (document.getElementById('articl_box').clientHeight + diff) + 'px';
//document.getElementById('articl_box').style.height = (document.getElementById('articl_box').getBoundingClientRect().height + diff) + 'px';
}
}
    
}

}
///////////////////////////////////////////////////////
function changeHeight(){
let widthWindow = window.innerWidth;
  if( widthWindow > 768 ){
    if( document.getElementById("altermenu") == null ){
        return true;
    }
    document.getElementById("altermenu").classList.remove("view_v");
    let searchForm = document.getElementById("searchFrm").firstElementChild;
    //alert(searchForm);
    let suchen = document.querySelector(".search_containr");
    //alert(suchen);
    if(searchForm != null){
      suchen.append(searchForm);
    }
    }
    //alert(this.event);
    if( widthWindow <= 768 && this.event != undefined ){
    let suchen = document.querySelector(".search_containr").firstElementChild;
    //alert('suchen = ' + suchen);
    let searchForm = document.getElementById("searchFrm");
    if(suchen != null){
      searchForm.append(suchen);
    }
    //alert(suchen.innerHTML);
    }
    
let rightSide = document.querySelector('.right_container');
if(rightSide && document.getElementById('articl_box')){
let imgLogo = document.querySelector('#imgLogo');
let logoHeight = '0px';
if(imgLogo != null){
  logoHeight = getComputedStyle(imgLogo).height;
}
let diff = rightSide.clientHeight + 30 - (document.getElementById('articl_box').clientHeight + +logoHeight.slice(0, logoHeight.length - 2));
if( diff > 0 && window.innerWidth >= 767 ){
document.getElementById('articl_box').style.height = (document.getElementById('articl_box').clientHeight + diff) + 'px';
}
}   
}

window.addEventListener('resize', changeHeight);

function showSuchen(){
let widthWindow = window.innerWidth;
    //alert(this.event);
    if( widthWindow <= 768 ){
    let suchen = document.querySelector(".search_containr").firstElementChild;
    //alert('suchen = ' + suchen);
    let searchForm = document.getElementById("searchFrm");
    if(suchen != null){
      searchForm.append(suchen);
    }
    //alert(suchen.innerHTML);
    }
}
window.addEventListener('load', showSuchen);

function closeAltermenu() {
  document.getElementById("altermenu").classList.remove("view_v");
}  

function showNavigV(event) {
  //  alert('OK' + ' ' + event); //.type); //.target);
  resizeWindw();
  let w = document.body.clientWidth;
  
  if( w <= 767 ){
    let suchen = document.querySelector(".search_containr").firstElementChild;
    let searchForm = document.getElementById("searchFrm");
    if(suchen != null){
      searchForm.append(suchen);
      //suchen.style.display = 'block';
    }
    //if( this.event == '[object MouseEvent]' ){
    if( event == '[object MouseEvent]' ){
       // alert(this.event == 'object MouseEvent');
       document.getElementById("altermenu").classList.toggle("view_v"); 
    }
  }else{
    document.getElementById("altermenu").classList.remove("view_v");
  }
  
  /*if( w <= 767 && this.event != undefined){
  document.getElementById("altermenu").classList.toggle("view_v");
  let suchen = document.querySelector(".search_containr").firstElementChild;
    //alert('suchen = ' + suchen);
    let searchForm = document.getElementById("searchFrm");
    if(suchen != null){
      searchForm.append(suchen);
    }
  }else{*/
  //document.getElementById("altermenu").classList.remove("view_v");
  /*var x = document.getElementById("myTopnav");
  if (x.className === "nav_horbar") {
    x.className += " responsive";
  } else {
    x.className = "nav_horbar";
  }*/
  //}
}
///////////////////////////////////////////////////////////////////////////////////
function Like(comntId, comment_span, user_id, unlike_btn_name) {
  var elems = document.getElementsByName(unlike_btn_name);
  for(var i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }
  var cnt = parseInt(document.getElementById(comment_span).innerHTML);
  cnt = cnt + 1;
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
     if (this.readyState == 4 && this.status == 200) {
      document.getElementById(comment_span).innerHTML = cnt;
    }
  };
  xhttp.open("POST", "/like?comment_id=" + comntId + '&comment_span=' + comment_span + '&user_id=' + user_id + '&count=' + cnt, true);
  xhttp.send();
}

function Unlike(comntId, comment_span, user_id, like_btn_name) {
  var elems = document.getElementsByName(like_btn_name);
  for(var i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }
  var cnt = parseInt(document.getElementById(comment_span).innerHTML);
  cnt = cnt + 1;
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById(comment_span).innerHTML = cnt;
    }
  };
  xhttp.open("POST", "/unlike?comment_id=" + comntId + '&comment_span=' + comment_span + '&user_id=' + user_id + '&count=' + cnt, true);
  xhttp.send();
}
///////////////////////////////////////////
//async function commentsArr(lng, min, max, step){ 
async function commentsArr(lng, min, max, step){
  let langObj = {};
  let lang = lng.toString();
  //let lang = 'en';
  let response = await fetch("/js/lang_features.json");
  if (response.ok) { 
    langObj = await response.json();
    //alert(langObj.more_comments[lang]);
  }else {
    alert("Error HTTP: " + response.status);
  }
  let name = urlFiltered();
  let maxShowed = +max;
  let cvalue = 0;
  let commentsArr = document.getElementsByClassName("comment_block");
  cvalue = +getCookie(name);
//update cookie ////////////////////////////////////////////////////////////////////// 
//setCookie(name, maxShowed, 5*60);
//update cookie end //////////////////////////////////////////////////////////////////

  if(min > 0){    
    document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 2].id ).style = 'display: none';
    
    if(cvalue > 0){
      maxShowed = cvalue + step;
      document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[cvalue - 2].id ).style = 'display: none';
    }else{
      maxShowed = max + step;
    }
    setCookie(name, maxShowed, 5*60);    
  }else{
    if(cvalue){
      maxShowed = cvalue;
    }else{
      maxShowed = max;
    }
  }
    let i = 0;
    for(let commentItem of commentsArr){
        if(i < maxShowed){
            document.getElementsByClassName('comment_block')[i].style = 'display:block';
        }
    i++;
    }
let para = document.createElement("span");
if(maxShowed < commentsArr.length){
para.innerHTML = '<button onclick="commentsArr(' + "'" + lang + "'" + ', ' + (+min + +step) + ', ' + (+maxShowed + 1) + ', ' + (+step) + ')" class="more_button">'
//para.innerHTML = '<button onclick="commentsMore(' + "'" + lang + "'" + ', ' + (+min + +step) + ', ' + (+maxShowed + 1) + ', ' + (+step) + ')" class="more_button">'
+ langObj.more_comments[lang] + step + '</button>';
let id = 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 1].id;
document.getElementById(id).appendChild(para);
}
//alert(maxShowed);
//dateFormat(min, lang, langObj, maxShowed); 

let commentelems = document.querySelectorAll('.comment_block');
let arrComnt = [];
for(let item of commentelems){
    if(getComputedStyle(item).display != 'none'){
        arrComnt.push(item);    
    }
}
//alert(arrComnt.length);
let horlin = commentelems[arrComnt.length - 1].querySelector('hr');
horlin.style.visibility = 'hidden';

}
//commentsArr(lng, min, max, step);
//commentsArr(lng, min, max, step); // 1
// Date Formatting////////////////////////////////////
function dateFormat(min, lang, langObj, commentsCnt){
    let frase;
    //alert(commentsCnt);
    let date_arr = document.querySelectorAll('span.date_comment');
    //alert(date_arr.length);
    //2020-05-08 13:32:46
    let y = +min;
    //for(let date of date_arr){
    for(; y < commentsCnt;){
        let date = date_arr[y];
        //if(i == 0){
            //alert(date.textContent);
            //alert(date.textContent.toString().slice(0, 4));
            /*let dateMod = new Date(date.textContent.toString().slice(0, 4),
            + date.textContent.toString().slice(5, 7), 
            + date.textContent.toString().slice(8, 10));
            alert(dateMod.getFullYear() + ' ' + dateMod.getMonth() + ' ' + dateMod.getDate());*/
            let dateMod = new Date(date.innerHTML);
            //alert(dateMod);
            let now = Date.now();
            let diff = +(now - dateMod)/1000;
            if (diff < 1){
                frase = langObj.time_ago_comment.less_sec[lang];
            }
            else if (diff < 60){
                frase = '&nbsp;' + Math.round(diff) + ' ' + langObj.time_ago_comment.less_minute[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600){
                frase = '&nbsp;' + Math.round(diff/60) + ' ' + langObj.time_ago_comment.less_hour[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600*24){
                frase = '&nbsp;' + Math.round(diff/3600) + ' ' + langObj.time_ago_comment.less_day[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600*24*30 && diff > 3600*24){
                frase = '&nbsp;' + Math.round(diff / 3600 / 24) + ' ' + langObj.time_ago_comment.less_month[lang] + '&nbsp;';
                date.innerHTML = frase;
            }if (diff > 3600*24*30){
            date.innerHTML = '&nbsp;' + date.textContent.substr(0, 10) + '&nbsp;';
            }
            //alert(diff);
            //alert(diff);
        //} 
    y++;
    }
}
// Date Formatting////////////////////////////////////

function urlFiltered(){
  let arrUrl = [];
  let shortcurrUrl;    
  let currentUrl = window.location.href.match(/^[^\#\?]+/)[0];
  if(currentUrl.indexOf('www.') != -1){
    shortcurrUrl = currentUrl.split('www.')[1];
    }
    shortcurrUrl = currentUrl.split('//')[1];
    return shortcurrUrl;
}

function getCookie(name) {
    let cookieArr = document.cookie.split(";"); 
       
    for(let i = 0; i < cookieArr.length; i++) {
        let cookiePair = cookieArr[i].split("=");        

        if(name == cookiePair[0].trim()) {
            return decodeURIComponent(cookiePair[1]);
        }
    }
    return "";
}

function setCookie(name, value, timeToLive) {
    let cookie = name + "=" + encodeURIComponent(value);
    
    if(typeof timeToLive === "number") {
        cookie += "; max-age=" + timeToLive;
        
        document.cookie = cookie;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
async function commentsMore(lng, min, max, step){ 
  let langObj = {};
  let lang = lng.toString();
  //let lang = 'en';
  let response = await fetch("/js/lang_features.json");
  if (response.ok) { 
    langObj = await response.json();
    //alert(langObj.more_comments[lang]);
  }else {
    alert("Error HTTP: " + response.status);
  }
  let name = urlFiltered();
  let maxShowed = +max;
  let cvalue = 0;
  let commentsArr = document.getElementsByClassName("comment_block");
  cvalue = +getCookie(name);
//update cookie ////////////////////////////////////////////////////////////////////// 
//setCookie(name, maxShowed, 5*60);
//update cookie end //////////////////////////////////////////////////////////////////

  if(min > 0){    
    document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 2].id ).style = 'display: none';
    
    if(cvalue > 0){
      maxShowed = cvalue + step;
      document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[cvalue - 2].id ).style = 'display: none';
    }else{
      maxShowed = max + step;
    }
    setCookie(name, maxShowed, 5*60);    
  }else{
    if(cvalue){
      maxShowed = cvalue;
    }else{
      maxShowed = max;
    }
  }
    let i = 0;
    for(let commentItem of commentsArr){
        if(i < maxShowed){
            document.getElementsByClassName('comment_block')[i].style = 'display:block';
        }
    i++;
    }
let para = document.createElement("span");
if(maxShowed < commentsArr.length){
para.innerHTML = '<button onclick="commentsMore(' + "'" + lang + "'" + ', ' + (+min + +step) + ', ' + (+maxShowed + 1) + ', ' + (+step) + ')" class="more_button">'
+ langObj.more_comments[lang] + step + '</button>';
let id = 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 1].id;
document.getElementById(id).appendChild(para);
}
//alert(maxShowed);
//dateFormat(lang, langObj, maxShowed); //****************************************************

let frase;
    //alert(commentsCnt);
    let date_arr = document.querySelectorAll('.date_comment');
    //alert(date_arr.length);
    //2020-05-08 13:32:46
    let y = +min;
    //for(let date of date_arr){
    for(; y < maxShowed;){
        let date = date_arr[y];
        //if(i == 0){
            //alert(date.textContent);
            //alert(date.textContent.toString().slice(0, 4));
            let dateMod = new Date(date.textContent);
            //alert(dateMod);
            //let now = Date.now();
            let now = new Date();
            let diff = +(now - dateMod)/1000;
            if (diff < 1){
                frase = langObj.time_ago_comment.less_sec[lang];
            }
            else if (diff < 60){
                frase = '&nbsp;' + Math.round(diff) + ' ' + langObj.time_ago_comment.less_minute[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600){
                frase = '&nbsp;' + Math.round(diff/60) + ' ' + langObj.time_ago_comment.less_hour[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600*24){
                frase = '&nbsp;' + Math.round(diff/3600) + ' ' + langObj.time_ago_comment.less_day[lang] + '&nbsp;';
                date.innerHTML = frase;
            }
            else if (diff < 3600*24*30 && diff > 3600*24){
                frase = '&nbsp;' + Math.round(diff/3600/24) + ' ' + langObj.time_ago_comment.less_month[lang] + '&nbsp;';
                date.innerHTML = frase;
            }if (diff > 3600*24*30){
            date.innerHTML = '&nbsp;' + date.textContent.substr(0, 10) + '&nbsp;';
            }
            //alert(diff);
        //} 
    y++;
    }

//********************************************************************************************
}
//commentsMore(lng, min, max, step);
///////////////////// propCollapsed [accordion vertical menu] //////////////////
function propCollapsed() {
  let hrefId = this.id;
  let pattern = 'coLLapse';
  let currID = hrefId.substr(1); //.substr(1);
  
  var match = pattern;
  var currentID = currID;
  var actualElem = "";
  var actualClassName = "";
  let chevron_actualElem = "";
  var cl = "";
  var actualID = "";
  var patrn = new RegExp(pattern, "i");
  var x = document.getElementsByClassName("collp");  //.getAttribute("id"); 
  var cl = document.getElementById(currentID).className;  
  var element = document.getElementById(currentID);
  var chevron_elem = document.getElementById(currentID.substr(8));
  var chevron_class = "";

  if( cl.substr(-2) != 'iN' ){
      element.classList.add("iN");
      chevron_elem.classList.toggle("bottom", true);
  }else{
      element.classList.remove("iN");
      chevron_elem.classList.toggle("bottom", false);
    }

  var i;
for (i = 0; i < x.length; i++) {
  if(x[i].id.match(patrn) != undefined){
    actualID = x[i].id.substr(1);
    actualElem = document.getElementById( actualID );
    actualClassName = actualElem.className;
    chevron_actualElem = document.getElementById( actualID.substr(8) );
    if( actualID != currentID ){
        if( actualClassName.substr(-2) === 'iN' ){
            actualElem.classList.remove("iN");
            chevron_actualElem.classList.toggle("bottom", false);
        }
    }
  }
}
//document.getElementById("demo").innerHTML = chevron_elem.className;
}

let collapsePanels = document.querySelectorAll('.collp');
for(let item of collapsePanels){
    item.addEventListener('click', propCollapsed);
}
//////////////////// propCollapsed END /////////////////////////////////////////

//////////////////// increase of height of article box /////////////////////////////
let archPanels = document.querySelectorAll('.acrd');
let archCollaps = document.querySelectorAll('.panel-collapse.collapse');

if( archPanels ){
  let i = 0;
  for( let item of archPanels ){
    item.addEventListener('click', collapsOther);
  i++;
  }
}

function collapsOther(){
    let aElem = this.querySelector('a');

    let hrefAttr = aElem.getAttribute('href');
    let panelId = hrefAttr.substr(1);
    let bodyCollapse = document.getElementById(panelId);
    let liList = bodyCollapse.querySelectorAll('li');
    let LineHeight = getComputedStyle(document.body).lineHeight;
    let liListHeight = liList.length * LineHeight.slice(0, LineHeight.length - 2) + 20;
    
    let rightSide = document.querySelector('.right_container');
    let imgLogo = document.querySelector('#imgLogo');
    let logoHeight = '0px';
    if(imgLogo != null){
      logoHeight = getComputedStyle(imgLogo).height;
    }

    let diff = rightSide.clientHeight + liListHeight - (document.getElementById('articl_box').clientHeight + +logoHeight.slice(0, logoHeight.length - 2));
    if( diff > 0 && window.innerWidth > 768){
        document.getElementById('articl_box').style.cssText = `height: ${(document.getElementById('articl_box').clientHeight + diff)}px; transition: height .35s ease-in-out`;
    }

}

let rightSide = document.querySelector('.right_container');
if(rightSide){
  let imgLogo = document.querySelector('#imgLogo');
  let logoHeight = '0px';
  if(imgLogo != null){
    logoHeight = getComputedStyle(imgLogo).height;
  }
  let diff = rightSide.clientHeight + 30 - (document.getElementById('articl_box').clientHeight + +logoHeight.slice(0, logoHeight.length - 2));
  if( diff > 0 && window.innerWidth >= 767 ){
    document.getElementById('articl_box').style.cssText = `height: ${(document.getElementById('articl_box').clientHeight + diff)}px; transition: height .35s ease-in-out`;
  }
}
//////////////////// END increase of height of article box END ////////////////

//document.addEventListener('resize', menuAlter);