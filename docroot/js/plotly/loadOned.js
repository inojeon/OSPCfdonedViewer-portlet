class OneDData {
  constructor(text) {
    this.readOneD(text)
  }

  readOneD(data){
    const lines = data.split('\n');
    this.xaxis = {};
    this.yaxis = {};
    this.field = [];

    for(let i = 0; i < lines.length; i++){
      if (lines[i][0] == '#'){
        const tempHeaderKey = lines[i].split(':')[0].split('#')[1].trim();
        if (tempHeaderKey =='NumField') {
          this.numField = lines[i].split(':')[1].trim();
        } else if (tempHeaderKey == 'LabelX') {
          this.xaxis.title = lines[i].split(",")[0].split(":")[1].trim();
          this.yaxis.title = lines[i].split(",")[1].split(":")[1].trim();
        } else if (new RegExp(/^Field/).test(tempHeaderKey) ) {
          const tempField = {};
          tempField.name = lines[i].split(",")[0].split(":")[1].trim();      //field별 이름 및 라인값 저장
          tempField.length = lines[i].split(",")[1].split(":")[1].trim();
          tempField.x = [];
          tempField.y = [];
          tempField.type = 'scatter';
          let k = 1;
          while ( !(lines[i+k][0] == '#')  ) {
            if(lines[i+k].trim() != '' ) {
              tempField.x.push(parseFloat(lines[i+k].trim().replace(/ +/g, " ").split(' ')[0]));
              tempField.y.push(parseFloat(lines[i+k].trim().replace(/ +/g, " ").split(' ')[1]));
            }
            k++;
            if( i+k >= lines.length){  break; }
          }
          i = i+k-1;
          this.field.push(tempField);
        }    // else if (new RegExp(/^Field/).test(tempHeaderKey) )
      }    //if (lines[i][0] == '#')
    }  // for(var i = 0; i < lines.length; i++)
  }
}

