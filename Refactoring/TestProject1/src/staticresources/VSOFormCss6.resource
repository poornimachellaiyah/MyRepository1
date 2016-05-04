::selection {
    background-color: #ad0075;
    color: white;
}

body {
  background-color: #fff;
  font-family: 'Calibri', 'Calibri', Calibri;
  font-size: 100%;
  margin: 0;
}

.mainPageDiv {
  position: static;
  margin: 0 auto;
  width: 100%;
}
div.pageTitle {
     font-size: 150%;
     font-weight: bold;   
}

div.pbBody {
  padding: 10px;
}

div.formPreText {
    margin: 0;
    display: none;
}

div.formTitleBlock {
  height: 86px;
  color: white;
    background-color: #ad0075;
  margin: 0;
  display: table;
    width: 100%;
}

.formTitle {
  height: 100%;
  width: 100%;
  text-align: right;
  display: table-cell;
  vertical-align: middle;
  font-size: 200%;
  text-shadow: 1px 1px 1px rgba(0,0,0,0.3);
  background-image: url('/resource/VSO_People_Logo');
  background-repeat: no-repeat;
  background-position: 4px 4px;
}

div.secondaryPalette {
  background-color: rgba(245,245,245,1);
  border:1px solid #ad0075;
  border-top: 3px solid #ad0075;
}

div.radioVerticalOption {
  text-indent: 0;
}

div.radioVerticalOption:hover {
  background-color: #181e23
}

input.pageButton, input.pageButtonDisabled {
  background-color: #ad0075;
  padding: 7px 30px;
  -webkit-border-radius: 8px;
  -moz-border-radius: 8px;
  -ms-border-radius: 8px;
  -o-border-radius: 8px;
  border-radius: 8px;
  color: white;
  font-weight: bold;
  cursor: pointer;
}


input.tabBlock:hover {
  background-color: #181e23
}

.tabBlock a.current {
    border-bottom-color: #181e23;
    border-left-color-value: #181e23;
    border-right-color-value: #181e23;
    border-top-color: #181e23;
    color: #181e23;
}

.tabBlock a {
    -moz-text-decoration-color: -moz-use-text-color;
    -moz-text-decoration-line: none;
    -moz-text-decoration-style: solid;
    background-color: #aaaaaa;
    border-bottom-style: none;
    border-bottom-width: medium;
    border-left-color-ltr-source: physical;
    border-left-color-rtl-source: physical;
    border-left-color-value: #37424a;
    border-left-style-ltr-source: physical;
    border-left-style-rtl-source: physical;
    border-left-style-value: solid;
    border-left-width-ltr-source: physical;
    border-left-width-rtl-source: physical;
    border-left-width-value: 1px;
    border-right-color-ltr-source: physical;
    border-right-color-rtl-source: physical;
    border-right-color-value: #37424a;
    border-right-style-ltr-source: physical;
    border-right-style-rtl-source: physical;
    border-right-style-value: solid;
    border-right-width-ltr-source: physical;
    border-right-width-rtl-source: physical;
    border-right-width-value: 1px;
    border-top-style: solid;
    border-top-width: 1px;
    font-weight: bold;
    padding-bottom: 5px;
    padding-left: 10px;
    padding-right: 10px;
    padding-top: 0;
    text-align: center;
}

input.pageButtonDisabled {
     background-color: grey;
     cursor: auto;   
}

div.pbBottomButtons {
    border-top: 4px solid #ad0075;
    padding: 10px;
}

input.pageButton:hover {
  background-color: #181e23
}

.questionTitle {
    font-size: 120%;
    font-weight: normal;   
    margin-bottom: 100px;
    margin-left: 0;
    margin-right: 0;
    margin-top: 20px;
    padding-bottom: 0;
    padding-left: 5px;
    padding-right: 5px;
    padding-top: 0;
}

td.questionPrompt {
  font-size: 100%;
  text-align: right;
  width: 50%;
}

.questionResponse {
        width: 50%;
        font-size: 100%
}

@media only screen and (min-width:960px) {
    .mainPageDiv {
        width: 960px;
    }
    
    .formTitle {
         text-align: center;   
    }
    
    td.questionPrompt {
        width: 33%;
    }
    
    .questionResponse {
        width: 67%;
    }
}

@media
only screen and (-webkit-min-device-pixel-ratio: 2)      and (min-width: 960px),
only screen and (   min--moz-device-pixel-ratio: 2)      and (min-width: 960px),
only screen and (     -o-min-device-pixel-ratio: 2/1)    and (min-width: 960px),
only screen and (        min-device-pixel-ratio: 2)      and (min-width: 960px),
only screen and (                min-resolution: 192dpi) and (min-width: 960px),
only screen and (                min-resolution: 2dppx)  and (min-width: 960px) { 
  body {
    font-size: 125%;
  } 

  .mainPageDiv {
        width: 100%;
    }
    
    .formTitle {
         text-align: right;   
    }
    
    td.questionPrompt {
        width: 50%;
    }
    
    .questionResponse {
        width: 50%;
    }
}