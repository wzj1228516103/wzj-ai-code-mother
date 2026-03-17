const fs = require('fs');
const content = fs.readFileSync('src/pages/app/AppChatPage.vue', 'utf8');

// Check style section
const styleMatch = content.match(/<style[^>]*>([\s\S]*)<\/style>/);
if (styleMatch) {
  const styleContent = styleMatch[1];
  let openBraces = 0;
  let closeBraces = 0;
  let balance = 0;
  let lineNum = 772; // style starts at line 772
  let colNum = 0;
  let firstExtraLine = null;
  
  for (let i = 0; i < styleContent.length; i++) {
    const char = styleContent[i];
    colNum++;
    if (char === '\n') {
      lineNum++;
      colNum = 0;
    }
    if (char === '{') {
      openBraces++;
      balance++;
    }
    if (char === '}') {
      closeBraces++;
      balance--;
      if (balance < 0 && !firstExtraLine) {
        firstExtraLine = lineNum;
        console.log('First extra closing brace found at line:', lineNum);
      }
    }
  }
  console.log('Style - Open braces:', openBraces);
  console.log('Style - Close braces:', closeBraces);
  console.log('Style - Difference:', openBraces - closeBraces);
}