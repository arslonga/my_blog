let bodyid = document.body.id;
let bodyObj = {
mjsimple_v: function(){ showNavigV() }  
}
/////////////////////////////////////////////////////////////
let iconV = document.querySelector('.top_panel a.icon');
//alert(iconV.className);
if(iconV){
    iconV.addEventListener('click', showNavigV);
}
/////////////////////////////////////////////////////////////

let pageAddress = window.location;
let myURL = new URL(pageAddress);
let pElem;
if( myURL.toString().match(/#comnt_/gi) ){
  let commentDiv = document.querySelector('#' + pageAddress.toString().split('#')[1]);
  pElem = commentDiv.querySelector('p');
  pElem.classList.add('recent_comment');
}
let currentSelected = document.querySelector('.recent_comment');
//checkScroll();

window.onscroll = function (e) { 
    //alert(e.target.tagName); 
let pageAddress = window.location;
let myURL = new URL(pageAddress);
let currentSelected = document.querySelector('.recent_comment');

if( myURL.toString().match(/#comnt_/gi) ){
  let commentDiv = document.querySelector('#' + pageAddress.toString().split('#')[1]);
  let pElemscroll = commentDiv.querySelector('p');
  if( currentSelected ){
    currentSelected.classList.remove('recent_comment');
  }
  pElemscroll.classList.add('recent_comment');
}

} 

///////////////////////////////////////////////
function resizeWindw(){
window.addEventListener('resize', go);
//go();
function go(){
  let widthWindow = window.innerWidth;
//  if( widthWindow > 768 ){
//    document.getElementById("altermenu").classList.remove("view_v");
//    }
    
let rightSide = document.querySelector('.right_container');
if(rightSide && document.getElementById('articl_box')){
let imgLogo = document.querySelector('#imgLogo');

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
  /*if( widthWindow > 768 ){
    if( document.getElementById("altermenu") == null ){
        return true;
    }
    document.getElementById("altermenu").classList.remove("view_v");
  }*/
    
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

function closeAltermenu() {
  document.getElementById("altermenu").classList.remove("view_v");
}  

////////////////////////////////////////////////////////////////////////////////
function showNavigV(event) {
  //  alert('OK' + ' ' + event); //.type); //.target);
  resizeWindw();
  let w = document.body.clientWidth;
  let h = window.innerHeight;
  
//  if( w <= 767 ){
if( event == '[object MouseEvent]' ){
    let altermenuContainer = document.querySelector('#altermenu');
    let liCollection = altermenuContainer.querySelectorAll('li');
    altermenuContainer.style.cssText = `height:${h - 46}px; position:fixed; top: 0; overflow-y: scroll`;
    document.getElementById("altermenu").classList.toggle("view_v");
    for( let item of liCollection ){
    if( item.querySelector('a') === null ){
      item.style.cssText = `background-image: url(/img/Lnohref_bg.png); font-weight:bold; font-size:18px; color: #E7E7E7`;
      //item.textContent += ' +';
      //if(!item.textContent.match(/\▼/g)){
      //  item.textContent += ' ▼';
      if(!item.textContent.match(/\+/g)){
        item.textContent += ' +';
      }
    }
  } 
}
//  }else{
//    document.getElementById("altermenu").classList.remove("view_v");
//  }

}
////////////////////////////////////////////////////////////////////////////////
function Like(comntId, comment_span, user_id, unlike_btn_name) {
  let elems = document.getElementsByName(unlike_btn_name);
  for(let i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }

  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
     if (this.readyState == 4 && this.status == 200) {
      document.getElementById(comment_span).innerHTML = this.responseText;
    }
  };
  xhttp.open("POST", "/like?comment_id=" + comntId + '&comment_span=' + comment_span + '&user_id=' + user_id, true);
  xhttp.send();
}

function Unlike(comntId, comment_span, user_id, like_btn_name) {
  let elems = document.getElementsByName(like_btn_name);
  for(let i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }

  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById(comment_span).innerHTML = this.responseText;
    }
  };
  xhttp.open("POST", "/unlike?comment_id=" + comntId + '&comment_span=' + comment_span + '&user_id=' + user_id, true);
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
    //setCookie(name, maxShowed, 31*86400);
    setCookie(name, maxShowed, 1*3600);  
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
let collapseAction = '';
let prevlistHeight = 0;
let diffPrev; // = 0;
let archPanels = document.querySelectorAll('.acrd');
//alert(archPanels.className);
let rightsidePrevHeight;
let rightsideHeight;

  for( let item of archPanels ){
    item.addEventListener('click', collapsOther);
  }

function collapsOther(event){ //*************************************************
    let aElem = this.querySelector('a');
    let hrefAttr = aElem.getAttribute('href');
    let panelId = hrefAttr.substr(1);
    let bodyCollapse = document.getElementById(panelId);
    
    //alert( window.location.href.match('archive') );
 //   alert('commentSectionHeight = ' + commentSectionHeight);

    let liList = bodyCollapse.querySelectorAll('li');
    listNumb = liList.length;
    let listCount = listNumb;
    if( listNumb > listNumbPrev ){
        listCount = listNumb - listNumbPrev;
    }
    let LineHeight = getComputedStyle(document.body).lineHeight;
    let liElem = bodyCollapse.querySelector('#li_archive_month');
    let liHeightpx = getComputedStyle(liElem).lineHeight; //.slice(0, lineHeight.length - 2);
    let liHeight = liHeightpx.slice(0, liHeightpx.length - 2);
    let liListHeight = Math.round(listCount * liHeight);
    
    let rightSide = document.querySelector('.right_container');
    if(imgLogo != null){
      logoHeight = imgLogo.clientHeight;
    }

    rightsideHeight = rightSide.clientHeight + liListHeight - logoHeight;
    if(rightsideHeight < rightsidePrevHeight ){
      rightsideHeight = rightsidePrevHeight;   
    }
    
    if( window.location.href.match('archive') == 'archive' ){
       //rightsideBegin = rightsideBegin - liListHeight; 
    }
    
    //alert(listNumb + ' : ' + listNumbPrev);
    //alert(liListHeight);
    
    if( bodyCollapse.matches('.in') == true ){
      if( (rightsideHeight > articlboxHeightBegin + liListHeight + 30) && window.innerWidth > 768 ){
        if( listNumb <= listNumbPrev ){
          articlBox.style.cssText = `height: ${(rightsideBegin + 90)}px; transition: height .2s ease-in-out`;
          //articlBox.style.cssText = `height: ${(rightsideHeight + liListHeight + 90)}px; transition: height .2s ease-in-out`;
        }else{
          if( window.location.href.match('archive') == 'archive' ){
            articlBox.style.cssText = `height: ${(rightsideBegin - logoHeight)}px; transition: height .2s ease-in-out`;
          }else{
            articlBox.style.cssText = `height: ${(rightsideHeight + 30 - logoHeight)}px; transition: height .2s ease-in-out`;
          }
        }
      }else{
        articlBox.style.cssText = `height: ${(document.height)}px; transition: height .2s ease-in-out`;
      }
      listNumb = 0;
      rightsidePrevHeight = rightsideHeight - 30;
      return true;
    }
    
    articlBox = document.getElementById('articl_box');
    articlboxHeight = articlBox.clientHeight;

    if( rightsideHeight > articlboxHeight - 30 && window.innerWidth > 768 ){
        if( listNumb > listNumbPrev ){
          articlBox.style.cssText = `height: ${(rightsideHeight + 30)}px; transition: height .2s ease-in-out`;
        }else{
          articlBox.style.cssText = `height: ${(rightsideBegin + liListHeight + 90 - logoHeight)}px; transition: height .2s ease-in-out`;
          listNumbPrev = listNumb;
        }
        rightsidePrevHeight = rightsideHeight - liListHeight;
        listNumbPrev = listNumb;
    }
    
    collapseAction = 'yes';
    //prevlistHeight = liListHeight;
    //diffPrev = diff;
    //alert('articlboxHeight_after = ' + articlBox.clientHeight);
} //*****************************************************************************

let rightSide = document.querySelector('.right_container');
//if(rightSide){
  let imgLogo = document.querySelector('#imgLogo');
  let logoHeight = 0;
  if( imgLogo != null ){
    logoHeight = imgLogo.clientHeight;
  }
  //alert(logoHeight);
  let articlBox = document.getElementById('articl_box');
  let articlboxHeight = articlBox.clientHeight;
  const articlboxHeightBegin = articlboxHeight;
  //alert(articlboxHeightBegin + commentSectionHeight);
  rightsideHeight = rightSide.clientHeight;
  const rightsideBegin = rightsideHeight;
  rightsidePrevHeight = rightsideHeight;
  let listNumb = 0;
  let listNumbPrev = listNumb;
  if( rightsideHeight > articlboxHeight && window.innerWidth > 768 ){
    articlBox.style.cssText = `height: ${(rightsideHeight + 30)}px; transition: height .35s ease-in-out`;
  }
//  }
//console.log('articlboxHeight_after = ' + document.getElementById('articl_box').clientHeight);
//}
//////////////////// END increase of height of article box END ////////////////

//document.addEventListener('resize', menuAlter);

//---------- Like/Unlike of article ------------------------------------------------------------------->
function LikeArtcl(titleAlias, articleId, vote_span, user_id, unlike_btn_name) {

  let elems = document.getElementsByName(unlike_btn_name);
  for(let i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }

  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
     if (this.readyState == 4 && this.status == 200) {
      document.getElementById(vote_span).innerHTML = this.responseText;
    }
  };
  xhttp.open("POST", "/likeartcl?title_alias=" + titleAlias + '&article_id=' + articleId + '&vote_span=' + vote_span + '&user_id=' + user_id, true);
  xhttp.send();
}

function UnlikeArtcl(titleAlias, articleId, vote_span, user_id, like_btn_name) {
  let elems = document.getElementsByName(like_btn_name);
  for(let i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }

  let xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById(vote_span).innerHTML = this.responseText;
    }
  };
  xhttp.open("POST", "/unlikeartcl?title_alias=" + titleAlias + '&article_id=' + articleId + '&vote_span=' + vote_span + '&user_id=' + user_id, true);
  xhttp.send();
}
//---------- Like/Unlike of article END ------------------------------------------------------------------->

//----------- SEARCH FORM BLOCK -------------------------------------------
function onclickFunc(event){
  if(event.target.matches('.search-icon')){
    let suchenContainer = document.querySelector('.suchen-style');
    suchenContainer.classList.add('show-search');
    let searchContainer = document.querySelector('.searcn-icon-container');
    searchContainer.innerHTML = `<span class="glyphicon glyphicon-remove close-icon"></span>`;
    document.forms.suchen.elements.search_frase.focus();
  }
  if(event.target.matches('.close-icon')){
    let searchContainer = document.querySelector('.searcn-icon-container');
    let suchenContainer = document.querySelector('.suchen-style');
    suchenContainer.classList.remove('show-search');
    searchContainer.innerHTML = `<span class="glyphicon glyphicon-search search-icon"></span>`;
  }
}
document.addEventListener('click', onclickFunc);
//----------- SEARCH FORM BLOCK END -------------------------------------------

///////////////--------------------/////////////////////////////////////
function __collapsOther(event){ //*************************************************
    let aElem = this.querySelector('a');
    let hrefAttr = aElem.getAttribute('href');
    let panelId = hrefAttr.substr(1);
    let bodyCollapse = document.getElementById(panelId);

    let liList = bodyCollapse.querySelectorAll('li');
    listNumb = liList.length;
    let listCount = listNumb;
    if( listNumb > listNumbPrev ){
        listCount = listNumb - listNumbPrev;
    }
    let LineHeight = getComputedStyle(document.body).lineHeight;
    let liElem = bodyCollapse.querySelector('#li_archive_month');
    let liHeightpx = getComputedStyle(liElem).lineHeight; //.slice(0, lineHeight.length - 2);
    let liHeight = liHeightpx.slice(0, liHeightpx.length - 2);
    let liListHeight = Math.round(listCount * liHeight);
    
    let rightSide = document.querySelector('.right_container');
    let imgLogo = document.querySelector('#imgLogo');
    let logoHeight = '0px';
    if(imgLogo != null){
      logoHeight = getComputedStyle(imgLogo).height;
    }
    rightsideHeight = rightSide.clientHeight + liListHeight - logoHeight.slice(0, logoHeight.length - 2);
    if(rightsideHeight < rightsidePrevHeight ){
      rightsideHeight = rightsidePrevHeight   
    }
    
    if( bodyCollapse.matches('.in') == true ){
      alert('rightsideHeight = ' + rightsideHeight + ' : rightsidePrevHeight = ' + rightsidePrevHeight);
      //articlBox.style.cssText = `height: ${(rightsideBegin + 30)}px; transition: height .2s ease-in-out`;
      rightsidePrevHeight = rightsideHeight - 20;
      //listNumbPrev = 0;
      //rightsideHeight = rightsideBegin + liListHeight - logoHeight.slice(0, logoHeight.length - 2);
      return true;
    }
    
    alert(listNumb + ' : ' + listNumbPrev);
    alert('liListHeight = ' + liListHeight);
    
    articlBox = document.getElementById('articl_box');
    articlboxHeight = articlBox.clientHeight;
    //console.log('articlboxHeight_clicked = ' + articlboxHeight + ' : ' + 'rightSide.clientHeight = ' + rightSide.clientHeight);

    alert('rightsideHeight = ' + rightsideHeight + ' : rightsidePrevHeight = ' + rightsidePrevHeight);
    if( rightsideHeight > articlboxHeight && window.innerWidth > 768 ){
        if( listNumb > listNumbPrev ){
          articlBox.style.cssText = `height: ${(rightsideHeight + 20)}px; transition: height .2s ease-in-out`;
        }else{
          listNumbPrev = listNumb;
        }
        rightsidePrevHeight = rightsideHeight - liListHeight;
        listNumbPrev = listNumb;
    }
    
    collapseAction = 'yes';
    //prevlistHeight = liListHeight;
    //diffPrev = diff;
    //alert('articlboxHeight_after = ' + articlBox.clientHeight);
} //*****************************************************************************