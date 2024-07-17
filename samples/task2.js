# Generic WHS
courses.generic_whs_initialize_select = (level) ->
  level_data = window.generic_whs_targets[level]
  $(level_data["id"]).select2({
    language:
      noResults: ->
        I18n.t('assets.javascripts.application.courses.select2.no_results')
    placeholder: I18n.t("assets.javascripts.application.courses.select_a_#{level}")
    width: "100%"
    dropdownParent: $(".fancybox-inner .import_generic_whs_popup").closest(".fancybox-wrap")
  })
  window.glg.new_design_shared.computeAndApplyBorder()
  $(document).off "select2:select", level_data["id"]
  $(document).on "select2:select", level_data["id"], ->
    courses.generic_whs_on_select(level)