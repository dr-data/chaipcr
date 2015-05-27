ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemp = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  on: false,

  capsuleTemplate: JST["backbone/templates/app/capsule"],

  initialize: function() {

    var that = this;
    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.on = data.autoDelta;

      if(that.on) {
        $(that.el).removeClass("disabled");
      } else {
        $(that.el).addClass("disabled");
      }

    });
  },

  render: function() {

    var data = {
      caption: "TEMP.",
      data: "2.0º"
    };

    $(this.el).html(this.template(data));
    // Disabling for now
    $(this.el).addClass("disabled");
    $(this.el).find(".caption-part").append(this.capsuleTemplate());

    this.draggable = new ChaiBioTech.app.Views.draggable({
      element: $(this.el).find(".ball-cover"),
      editStepStageClass: this.options.editStepStageClass
    });

    return this;
  }
});
