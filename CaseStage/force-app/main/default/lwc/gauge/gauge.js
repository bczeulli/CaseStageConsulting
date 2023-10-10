import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

const INVALID_FIELD = "Invalid field";
const NO_FIELD_SELECTED = "No field selected";
const PERCENT_TYPE_SUPPORTED = 'Only fields of type "Percent" are supported';
const LIMIT1_GREATER_THAN_LIMIT2 = "Limit 2 must be greater than the Limit 1";
const FIELDS = ["Opportunity.LastStageChangeDate","Opportunity.CloseDate", "Opportunity.StageName"];
const dataAtual = new Date().toISOString();
const dataAtualObj = new Date(dataAtual);

export default class Gauge extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api title;
    @api inputFieldApiName;
    @api limit1;
    @api limit2;
    @api gaugeColor1;
    @api gaugeColor2;
    @api gaugeColor3;
    gaugeColor;
    value = 0;
    error;
    fieldValue;
    textMessage;
    daysDiference;
    stageName;
  
    /**
     * load the record data
     */
    @wire(getRecord, {
      recordId: "$recordId",
      fields: "$objectApiNameDotfieldApiName",
      optionalFields: FIELDS
    })
    loadRecord({ error, data }) {
      if (error) {
        if (this.fieldApiName) {
          this.error = INVALID_FIELD;
        } else {
          this.error = NO_FIELD_SELECTED;
        }
      } else if (data) {
        let field = data.fields[this.fieldApiName];
        let diferencaEmDias;
        let dataFornecida;
        let dataFornecidaObj;
        if (field) {
          console.log('data',data);
          this.fieldValue = data.fields.Probability.value;
          this.stageName = data.fields.StageName.value;
          dataFornecida = data.fields.CloseDate.value;
          dataFornecidaObj = new Date(dataFornecida).toISOString();
          let data2 = new Date(dataFornecidaObj);
          let data3 = diferencaEmDias = Math.floor((data2 - dataAtualObj) / (1000 * 60 * 60 * 24));
          this.daysDiference = data3;

          switch (true) {
            case this.daysDiference > 59 :
              this.textMessage = 'Extremamente Satisfeito: Probabilidade muito alta';
              if(this.stageName == 'Formalização'){
                this.setGaugeValue(90);
              } else{
                this.setGaugeValue(60);
              }
              break;
            case this.daysDiference < 45 && this.daysDiference >= 30:
              this.textMessage = 'Muito Satisfeito: Probabilidade boa';
              if(this.stageName == 'Formalização'){
                this.setGaugeValue(80);
              } else{
                this.setGaugeValue(50);
              }
              break;
            case this.daysDiference < 30 && this.daysDiference >= 20:
              this.textMessage = 'Satisfeito: Probabilidade moderada';
              if(this.stageName == 'Formalização'){
                this.setGaugeValue(70);
              } else{
                this.setGaugeValue(40);
              }
              break;
            case this.daysDiference < 20 && this.daysDiference >= 10:
              this.textMessage = 'Pouco Satisfeito: Baixa probabilidade';
              if(this.stageName == 'Formalização'){
                this.setGaugeValue(50);
              } else{
                this.setGaugeValue(30);
              }
              break;
            case this.daysDiference < 10 :
              this.textMessage = 'Insatisfeito: Probabilidade muito baixa';
              if(this.stageName == 'Formalização'){
                this.setGaugeValue(40);
              } else{
                this.setGaugeValue(10);
              }
              break;    
            default:
              this.textMessage;
              break;
          }
        }
      }
    }
  
    /**
     * load the object info
     */
    @wire(getObjectInfo, { objectApiName: "$objectApiName" })
    loadObjectInfo({ error, data }) {
      if (error) {
        if (this.fieldApiName) {
          this.error = INVALID_FIELD;
        } else {
          this.error = NO_FIELD_SELECTED;
        }
      } else if (data) {
        let field = data.fields[this.fieldApiName];
        if (field) {
          // check if selected type is of type "Percent"
          if (field.dataType !== "Percent") {
            this.error = PERCENT_TYPE_SUPPORTED;
          }
        }
      }
    }
  
    /**
     * set the Gauge value
     * @param {*} value value to set
     */
    setGaugeValue(value) {
      this.value = 0;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      let setValue = setInterval(() => {
        if (this.value < value) {
          this.value += 1;
          this.setGaugeColor(this.value);
        } else {
          clearInterval(setValue);
        }
      }, 10);
    }
  
    /**
     * set the Gauge color
     * @param {*} value value from which de color will be computed
     */
    setGaugeColor(value) {
      // validate limit coherence
      if (this.limit1 >= this.limit2) {
        this.error = LIMIT1_GREATER_THAN_LIMIT2;
        return;
      }
      if (value < this.limit1) {
        this.gaugeColor = this.gaugeColor1;
      } else if (value < this.limit2) {
        this.gaugeColor = this.gaugeColor2;
      } else {
        this.gaugeColor = this.gaugeColor3;
      }
    }
  
    //=====================================================================
    //============================ getters ================================
    //=====================================================================
  
    /**
    * field API Name
    */
    get fieldApiName() {
      if (this.inputFieldApiName) {
        return this.inputFieldApiName.trim(); // trim
      }
      return this.inputFieldApiName;
    }
  
    /**
     * ObjectApiName.FieldApiName
     */
    get objectApiNameDotfieldApiName() {
      return this.objectApiName + "." + this.fieldApiName;
    }
  
    /**
     * Dynamic CSS for Gauge C
     */
    get styleGaugeC() {
      let styles = [
        `transform: rotate(${this.value / 200}turn)`,
        `background-color: ${this.gaugeColor}`
      ];
      return styles.join(";");
    }
}