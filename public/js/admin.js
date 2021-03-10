'use strict';

function readTextFile(file){
    let pleaseWaitMessage;
    let rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                pleaseWaitMessage = rawFile.responseText;
            }
        }
    }
    rawFile.send(null);
return pleaseWaitMessage;
}

function closeModal(){
  let bgAlert = document.getElementById('bg-modal');
  let messageBlock = document.getElementById('message-block');
  let messageContainer = messageBlock.querySelector('.alert-message-style');
  let pElement = messageContainer.querySelector('p');
  pElement.innerHTML = '';
  bgAlert.style.cssText = `display: none`;
  messageContainer.style.cssText = `display: none`;
  
document.body.style.cssText = `overflow: visible`;
return false;
}

function showAlertPanel(messageText){
let bgAlert = document.getElementById('bg-modal');
let messageBlock = document.getElementById('message-block');
let messageContainer = messageBlock.querySelector('.alert-message-style');
messageContainer.insertAdjacentHTML('afterbegin', messageText);
bgAlert.style.cssText = `display: block; top: 0; left: 0; height: ${document.documentElement.scrollHeight}px; width: 100%`;
messageContainer.style.cssText = `display: block`;
document.body.style.cssText = `overflow: hidden`;
}

function firstSymbWarn(message){
  showAlertPanel(`<p style="color:red">${message}</p>`);
  return false;
}

function emptyFieldWarn(fieldname){
  showAlertPanel(`<p style="color:red"><b>'${fieldname}'</b> field is empty</p>`);
  return false;
}

function checkNoLatin(inputtxt, messageText){
let letters = /^[\_\dA-Za-z]+$/;
  if(inputtxt.match(letters) == null){
    event.preventDefault();
    showAlertPanel(messageText);
    return false;
  }
}

function checkFillForm(event){
  let submitButn = event.target.querySelector("input[type=submit]");
  let submitName = submitButn.name;
  let lang = readTextFile( '/js/site_lang' );
  let response = readTextFile( '/js/lang_features.json' );
  let data = JSON.parse(response);

  if( submitName == 'edit' ){
    //alert('event.target = ' + event.target.edit.name + ' data = ' + data);
    let titleVal = event.target.querySelector("input[name=title]").value;
    if( titleVal.length < 1 ){
      event.preventDefault();
      emptyFieldWarn('Title');
      return false;
    }
    event.target.edit.value = data.please_wait[lang];
  }
  if( submitName == 'add'){
    let newtitleVal = event.target.querySelector("input[name=new_title]").value;
    let newtitleAlias = event.target.querySelector("input[name=new_title_alias]").value;
    
    if( newtitleAlias[0] && ( newtitleAlias[0].match(/\d/) || newtitleAlias[0].match(/\_/)) ){
      event.preventDefault();
      firstSymbWarn('The first character cannot be a number or an underscore');
      return false;
    }
    if( newtitleVal.length < 1 ){
      event.preventDefault();
      emptyFieldWarn('New section');
      return false;
    }
    if( newtitleAlias.length < 1 ){
      event.preventDefault();
      emptyFieldWarn('Alias (eng.)');
      return false;
    }
    
    let notationChecked = checkNoLatin( newtitleAlias, '<p style="color:red">No latin characters in Alias!</p>' );

    if( notationChecked === undefined ){
        event.target.add.value = data.please_wait[lang];
    return true;
    }
  }

return true;
}

let closeButton;
let locationHref = window.location.href;
if( locationHref.match(/menu_manage/) || locationHref.match(/menu_manage?/) ){
    closeButton = document.querySelector('#close-button');
    document.addEventListener( 'submit', checkFillForm, false );
    closeButton.addEventListener('click', closeModal);
}