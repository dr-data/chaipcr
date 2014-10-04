ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomRampSpeed = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {
    var that = this;
    // Works when step is clicked
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.currentStep = data;
      that.changeRampSpeed();
    });
    // Works when circle is dragged
    this.listenTo(this.options.editStepStageClass, "stepDrag", function(data) {
      that.currentStep = data;
    });
  },

  events: {
      "click .data-part": "startEdit",
      "blur .data-part-edit-value": "saveDataAndHide",
      "keydown .data-part-edit-value": "seeIfEnter"
  },

  startEdit: function() {
    this.dataPartEdit.show();
    this.dataPartEdit.focus();
  },

  saveDataAndHide: function() {
    var newRampSpeed = this.dataPartEdit.val();
    this.dataPartEdit.hide();
    if(isNaN(newRampSpeed) || !newRampSpeed || newRampSpeed < 0 || newRampSpeed > 100) {
      var tempVal = this.dataPart.html()
      this.dataPartEdit.val(tempVal);
      alert("Please enter a valid value");
    } else {
      newRampSpeed = parseInt(newRampSpeed);
      this.currentStep.model.changeRampSpeed(newRampSpeed);
      var display = (newRampSpeed === 0) ? "MAX" : newRampSpeed;
      this.dataPart.html(display);
      // Now fire it back to canvas
      this.currentStep.rampSpeedNumber = newRampSpeed;
      ChaiBioTech.app.Views.mainCanvas.fire("rampSpeedChangedFromBottom", this.currentStep);
    }
  },

  seeIfEnter: function(e) {
    if(e.keyCode === 13) {
      this.dataPartEdit.blur();
    }
  },

  changeRampSpeed: function() {
    if(this.currentStep.rampSpeedNumber === 0) {
      this.dataPart.html("MAX");
      this.dataPartEdit.val(0)
    } else {
      this.dataPart.html(this.currentStep.rampSpeedNumber);
      this.dataPartEdit.val(parseInt(this.currentStep.rampSpeedNumber));
    }
  },

  render: function() {
    var data = {
      caption: "RAMP SPEED",
      data: "MAX"
    }
    $(this.el).html(this.template(data));
    this.dataPart = $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");
    return this;
  }
});
