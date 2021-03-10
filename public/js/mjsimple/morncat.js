
let pageAddress = window.location;
let myURL = new URL(pageAddress);
let pElem;
if( myURL.toString().match(/#comnt_/gi) ){
  let commentDiv = document.querySelector('#' + pageAddress.toString().split('#')[1]);
  pElem = commentDiv.querySelector('p');
  pElem.classList.add('recent_comment');
}

async function commentBlock( commentBlocks ){ /////////////////////////////
let confObj = {};

  let response = await fetch("/js/config.json");
  if (response.ok) { 
    confObj = await response.json();
  }else {
    alert("Error HTTP: " + response.status);
  }

comntPclass = confObj.commentPclass;
let commentBlockSelector = 'p.' + comntPclass;

for( let item of commentBlocks ){
    
    if( item.className.match(/dev/gi) ){
        //let pElem = item.querySelector('p');
        let pElem = item.querySelector( commentBlockSelector );

        //if( pElem.className != 'recent_comment' ){
        if( !pElem.className.match(/recent_comment/gi) ){
            pElem.classList.add('answer_comment');
        }
    }
}
} //////////////////////////////////////////////////////////////////////////

let commentDiv = document.querySelectorAll('.comment_block');
if( commentDiv ){
    commentBlock(commentDiv);
}

window.onscroll = async function (e) { ///////////////////////////////////////////////
let h = window.innerHeight;
let toTopbutton;
let comntPclass;

let confObj = {};

  let response = await fetch("/js/config.json");
  if (response.ok) { 
    confObj = await response.json();
  }else {
    alert("Error HTTP: " + response.status);
  }
comntPclass = confObj.commentPclass;
let commentBlockSelector = 'p.' + comntPclass;

if( pageYOffset > h*0.2 ){
  toTopbutton = document.querySelector('.to-top');
  toTopbutton.style.cssText = `display: block; top: ${h - 150}px`;
}else{
  toTopbutton = document.querySelector('.to-top');
  toTopbutton.style.display = 'none';
}

let pageAddress = window.location;
let myURL = new URL(pageAddress);
let currentSelected = document.querySelector('.recent_comment');

if( myURL.toString().match(/#comnt_/gi) ){
  let commentDiv = document.querySelector('#' + pageAddress.toString().split('#')[1]);
  let pElemscroll = commentDiv.querySelector( commentBlockSelector );
  if( currentSelected ){
    currentSelected.classList.remove('recent_comment');
    currentSelected.classList.add('answer_comment');
  }
  pElemscroll.classList.add('recent_comment');
  let newStatus = document.querySelector('.answer_comment.recent_comment');
  if(newStatus){
    newStatus.classList.remove('answer_comment');
  }
  
  let commentBlocks = document.querySelectorAll('.comment_block');
  for( let item of commentBlocks ){
    if( !item.className.match(/dev/gi) ){
      let pElem = item.querySelector( commentBlockSelector );
      pElem.classList.remove('answer_comment');
    }
  }
}

} /////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
function menuAlter(){
let w = window.innerWidth;
let h = window.innerHeight;
let poSition;
let alternavContainer = document.querySelector('#alternav');
let alternavHeight = alternavContainer.getBoundingClientRect().height;
let coordY = scrollY;

/*if(alternavContainer.matches('.view')){
  alternavContainer.classList.remove("view");   
}*/

if(alternavHeight >= h){
  poSition = 'absolute';
}else{
  poSition = 'fixed';
  coordY = 0;
}
return [poSition, coordY];
}

//////////////////////////////////////////////
/* When the user clicks on the button, 
toggle between hiding and showing the dropdown content */
function showDropdown(dropdownId) { //////////////////////////////////////////
  let elemId = [];
  let currId = document.getElementById(dropdownId);
  currId.classList.toggle("show");
  let classCollect = document.getElementsByClassName('dropdown-content');
  let i;
  for (i = 0; i < classCollect.length; i++) {
    elemId[i] = classCollect[i].id;
    if( elemId[i] != dropdownId ){
      document.getElementById(elemId[i]).classList.remove('show');
      //alert(document.getElementById(elemId[i]).previousElementSibling);
      document.getElementById(elemId[i]).previousElementSibling.classList.remove('hoverbg');
    }
  }
}
// Close the dropdown if the user clicks outside of it
document.onclick = function(e) {

if (!e.target.matches('.dropbtn')) {
  let myDropdownCollect = document.querySelectorAll('.drop_down');
  for( item of myDropdownCollect ){
    item.querySelector('.dropdown-content').classList.remove('show');
    let buttoDropdwn = item.firstElementChild; 
    buttoDropdwn.classList.remove('hoverbg');
  }
  }

  document.onmouseout = function(){
    let myDropdownCollect = document.querySelectorAll('.drop_down');
    for( item of myDropdownCollect ){
      let buttoDropdwn = item.firstElementChild;
      if(item.querySelector('.dropdown-content').classList.contains('show')){
        //let buttoDropdwn = item.firstElementChild; 
        buttoDropdwn.classList.add('hoverbg');
      }else{
        buttoDropdwn.classList.remove('hoverbg');
      }
    }
    
  }
  
  if( e.target.closest('.to-top') ){
    window.scroll(0, 0);
  }
}////////// showDropdown(dropdownId) END ///////////////////////////////////////

function showNavig() { //********************************
  //let posAndYarray = window.addEventListener('resize', menuAlter);

  let w = window.innerWidth;
  let h = window.innerHeight;
  
  let alternavContainer = document.querySelector('#alternav');
  let liCollection = alternavContainer.querySelectorAll('li');

  alternavContainer.style.cssText = `height:${h - 46}px; position:fixed; top: 0; overflow-y: scroll`;
  document.getElementById("alternav").classList.toggle("view");

  for( let item of liCollection ){
    if( item.querySelector('a') === null ){
      item.style.cssText = `background-image: url(/img/Lnohref_bg.png); font-weight:bold; font-size:18px; color: #E7E7E7`;
      //item.textContent += ' +';
      if(!item.textContent.match(/\▼/g)){
        item.textContent += ' ▼';
      //if(!item.textContent.match(/\+/g)){
      //  item.textContent += ' +';
      }
    }
  }

}//******************************************

function _showNavig() { //********************************
  window.addEventListener('resize', menuAlter);
  let w = window.innerWidth;
  let logoutIcon = document.querySelector('.glyphicon-log-out');
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
async function commentsArr(lng, min, max, step){ 
  let moreId;
  let langObj = {};
  let lang = lng.toString();

  let response = await fetch("/js/lang_features.json");
  if (response.ok) { 
    langObj = await response.json();
  }else {
    alert("Error HTTP: " + response.status);
  }
  let name = urlFiltered();
  let maxShowed = +max;
  let cvalue = 0;
  let commentsArray = document.getElementsByClassName("comment_block");
  cvalue = +getCookie(name);

  if(min > 0){    
    document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 2].id ).style.display = 'none';
    
    if(cvalue > 0){
      maxShowed = cvalue + step;
      document.getElementById( 'moreDiv' + document.getElementsByClassName('comment_block')[cvalue - 2].id ).style.display = 'none';
    }else{
      maxShowed = max + step;
    }
    setCookie(name, maxShowed, 365*86400); 
    //setCookie(name, maxShowed, 1*3600);
  }else{
    if(cvalue){
      maxShowed = cvalue;
    }else{
      maxShowed = max;
    }
  }
  
  let i = 0;
    for(let commentItem of commentsArray){
        if(i < maxShowed){
            document.getElementsByClassName('comment_block')[i].style.display = 'block';
        }
        if(i >= maxShowed){
            document.getElementsByClassName('comment_block')[i].style.display = 'none';
        }
    i++;
    }
    
let para = document.createElement("span");
if(maxShowed < commentsArray.length){

  moreId = 'moreDiv' + document.getElementsByClassName('comment_block')[maxShowed - 1].id;
    
para.innerHTML = '<button onclick="commentsArr(' + "'" + lang + "'" + ', ' + (+min + +step) + ', ' + (+maxShowed + 1) + ', ' + (+step) + ')" class="more_button">'
+ langObj.more_comments[lang] + step + '</button>';
document.getElementById(moreId).append(para);
}

let commentelems = document.querySelectorAll('.comment_block');
let arrComnt = [];
for(let item of commentelems){
    if(getComputedStyle(item).display != 'none'){
        arrComnt.push(item);    
    }
}
let horlin = commentelems[arrComnt.length - 1].querySelector('hr');
if( horlin ){
    horlin.style.visibility = 'hidden';
}

}

////////////////////////////// Sctoll to anchor ////////////////////////////////
/*function scrollTo(event) {
    //alert(event.target);
    if( event.target.toString().match(/^[^\#\?]+/) ){
        let anchorElem = event.target.toString();
        let scrollToElemId = anchorElem.split('#')[1];
        let scrollToElem = document.getElementById(scrollToElemId);
        //alert(scrollToElem);
        scrollToElem.scrollIntoView( { behavior: "smooth" } );   
    }    
    //location.hash = "#" + hash;
}
//let currentHash = window.location.href.match(/^[^\#\?]+/);
//let currentHash = window.location.href.split('#')[1];
//alert( currentHash );
document.addEventListener( 'click', scrollTo );
*/
////////////////////////////// Sctoll to anchor END ////////////////////////////////

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

let alterNav = document.querySelector('#alternav');
let alterNavHeight = alterNav.getBoundingClientRect().height;
if( window.innerHeight < alterNavHeight ){
    alterNav.style.position = 'absolute';
}
//document.addEventListener('resize', menuAlter);

//---------- Like/Unlike of article ------------------------------------------------------------------->
function LikeArtcl(titleAlias, articleId, vote_span, user_id, unlike_btn_name) {
    //alert(vote_span);
  var elems = document.getElementsByName(unlike_btn_name);
  for(var i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }
  var cnt = parseInt(document.getElementById(vote_span).innerHTML);
  //alert('cnt = ' + cnt);
  cnt = cnt + 1;
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
  //alert(this.readyState + ' ' + this.status);
     if (this.readyState == 4 && this.status == 200) {
      document.getElementById(vote_span).innerHTML = cnt;
    }
  };
  xhttp.open("POST", "/likeartcl?title_alias=" + titleAlias + '&article_id=' + articleId + '&vote_span=' + vote_span + '&user_id=' + user_id + '&count=' + cnt, true);
  xhttp.send();
}

function UnlikeArtcl(titleAlias, articleId, vote_span, user_id, like_btn_name) {
  var elems = document.getElementsByName(like_btn_name);
  for(var i = 0; i < elems.length; i++) {
    elems[i].disabled = true;
  }
  var cnt = parseInt(document.getElementById(vote_span).innerHTML);
  cnt = cnt + 1;
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      document.getElementById(vote_span).innerHTML = cnt;
    }
  };
  xhttp.open("POST", "/unlikeartcl?title_alias=" + titleAlias + '&article_id=' + articleId + '&vote_span=' + vote_span + '&user_id=' + user_id + '&count=' + cnt, true);
  xhttp.send();
}
//---------- Like/Unlike of article END ------------------------------------------------------------------->

//----------- HIDDEN COMMENT ------------------------------------------
let hiddenComment = document.querySelectorAll('.comment_hidden');
for( let item of hiddenComment ){
  let nextSiblingHr = item.parentElement.nextElementSibling;
  nextSiblingHr.style.display = 'none';
}

//----------- HIDDEN COMMENT END ------------------------------------------

//----------- SEARCH FORM BLOCK -------------------------------------------
function closeModal(){
  let frontWindow = document.getElementById('front-window');
  let suchenBlock = document.getElementById('suchen-block');
  let suchenContainer = suchenBlock.querySelector('.suchen-style');
  frontWindow.style.cssText = `display: none`;
  suchenContainer.style.cssText = `top: -130px;`;
  
  document.body.style.cssText = `overflow: visible`;
}

function showSearchForm(){
  window.scroll({
    top: 0,
    left: 0,
    behavior: "smooth"
  });
  let frontWindow = document.getElementById('front-window');
  let suchenBlock = document.getElementById('suchen-block');
  let suchenContainer = suchenBlock.querySelector('.suchen-style');
  frontWindow.style.cssText = `display: block; top: 0; left: 0; height: ${document.documentElement.scrollHeight}px; width: 100%`;
  suchenContainer.style.cssText = `top: 100px; transition: top 0.3s`;
  document.forms.suchen.elements.search_frase.focus();
  
  document.body.style.cssText = `overflow: hidden`;
}

let searchIcon = document.querySelector('.search-icon');
let closeButton = document.querySelector('#close-button');
if(searchIcon){
  searchIcon.addEventListener("click", showSearchForm);
}
if(closeButton){
  closeButton.addEventListener("click", closeModal);
}
//----------- SEARCH FORM BLOCK END -------------------------------------------

//----------- VIEW PASSWORD -------------------------------------------
function changeFieldType(e){
  if( passwField.type === 'password' ){
    passwField.type = 'text';
  return true;
  }
  if( passwField.type === 'text' ){
    passwField.type = 'password';
  return true;
  }

}

let passwField = document.getElementById('reset_passw');
let checkboxTumbler = document.getElementById('viewpassw');
if( checkboxTumbler ){
  checkboxTumbler.addEventListener( 'change', changeFieldType );
}
//----------- VIEW PASSWORD END -------------------------------------------

//----------- SCROLL TO ERROR LOCATION ON page with comments -------------------
let fieldWithErr = document.querySelector('.field-with-error');
let errMessage = document.querySelector('#comnt-label').nextElementSibling.innerHTML;
console.log('fieldWithErr = ' + fieldWithErr + ' - ' + 'errMessage = ' + errMessage);
if( fieldWithErr || errMessage ){
    window.location.href = window.location.href + '#err-locat';
}
//----------- SCROLL TO ERROR LOCATION END -------------------------------------