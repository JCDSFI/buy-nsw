(function () {
  'use strict'
  window.ProcurementHub = window.ProcurementHub || {}

  function DetailedExpandingListModule (options) {
    this.$el = options.$el
    this.$template = this.buildTemplateForm()
    this.$container = this.$el.find('ol')

    this.inlineLabels = this.hasInlineLabels()
    this.objectName = this.$el.attr('data-object-name')
    this.maxItems = this.$el.attr('data-expanding-list-max')

    if (this.objectName == null) {
      this.objectName = 'row'
    }

    this.$addLink = this.buildAddLink()

    this.setupForm()
  }

  DetailedExpandingListModule.prototype.setupForm = function setupForm () {
    this.$el.addClass('expanding-list')

    if (!this.listFull()) {
      this.insertAddLink()
    }

    // Only add delete links to the rows which exist in the database, not new
    // empty ones. We can check for this by finding the ones which have an
    // existing value in the 'id' hidden field.
    //
    var $rows = this.$container.find('li:has(input[type=hidden][value])')
    $($rows).each(
      $.proxy(this.buildDeleteLink, this)
    )
  }

  DetailedExpandingListModule.prototype.addNewRow = function addNewRow (event) {
    event.preventDefault()

    if (this.listFull() === true) {
      return false
    }

    var $newRow = this.$template.clone()

    var $inputs = $newRow.find('input, select')

    var newIndex = this.getNewIndex()
    var visibleIndex = newIndex + 1

    $inputs.each($.proxy(function (i, input) {
      var $input = $(input)
      var $label = $input.siblings('label')

      if (this.inlineLabels === true) {
        $label.text(visibleIndex + '.')
      }

      if ($input.attr('id') !== undefined) {
        $label.attr('for', this.buildFieldID(
          $input.attr('id'), newIndex
        ))

        $input.attr('id', this.buildFieldID(
          $input.attr('id'), newIndex
        ))
      }

      if ($input.attr('name') !== undefined) {
        $input.attr('name', this.buildFieldName(
          $input.attr('name'), newIndex
        ))
      }
    }, this))

    var $deleteCheckboxWrapper = $newRow.find('*[data-expanding-list-delete]')
    $deleteCheckboxWrapper.hide()

    $newRow.appendTo(this.$container)
    $inputs.first().focus()

    if (this.listFull()) {
      this.removeAddLink()
    }
  }

  DetailedExpandingListModule.prototype.listFull = function listFull () {
    return (this.maxItems !== null && this.$container.find('li:not(.removed)').length >= this.maxItems)
  }

  DetailedExpandingListModule.prototype.deleteRow = function deleteRow ($row, event) {
    event.preventDefault()

    var $inputField = $row.find('input[type=text], select')
    var $deleteLink = $row.find('a')
    var $deleteCheckboxInput = $row.find('*[data-expanding-list-delete] input')

    $row.addClass('removed')
    $inputField.attr('disabled', true)
    $deleteCheckboxInput.attr('checked', true)
    $deleteLink.remove()

    if (this.listFull() === false) {
      this.insertAddLink()
    }
  }

  DetailedExpandingListModule.prototype.buildAddLink = function buildAddLink () {
    var $addLink = $('<a></a>')
    $addLink.text('Add another ' + this.objectName)
    $addLink.attr('href', '#')

    return $addLink
  }

  DetailedExpandingListModule.prototype.insertAddLink = function insertAddLink () {
    // Always remove the link to avoid doubling-up
    this.$addLink.remove()

    this.$addLink.appendTo(this.$el)
    this.$addLink.on('click', $.proxy(this.addNewRow, this))
  }

  DetailedExpandingListModule.prototype.removeAddLink = function removeAddLink () {
    this.$addLink.remove()
  }

  DetailedExpandingListModule.prototype.buildDeleteLink = function buildDeleteLink (i, element) {
    var $deleteContainer = $('<div></div>').addClass('delete-action')
    var $deleteLink = $('<a></a>')
    var $element = $(element)

    var $deleteCheckboxWrapper = $element.find('*[data-expanding-list-delete]')
    $deleteCheckboxWrapper.hide()

    $deleteLink.text('Delete this ' + this.objectName)
    $deleteLink.attr('href', '#')
    $deleteLink.on('click', $.proxy(this.deleteRow, this, $element))

    $deleteLink.appendTo($deleteContainer)
    $deleteContainer.appendTo($element)
  }

  DetailedExpandingListModule.prototype.buildTemplateForm = function buildTemplateForm () {
    var $templateForm = this.$el.find('li:first-of-type').clone()

    var $textInput = $templateForm.find('input[type=text]')
    var $selectInput = $templateForm.find('select')

    $textInput.val('')

    // Reset the selected value in any dropdown boxes
    $.each($selectInput, function (i, item) {
      var $item = $(item)
      var defaultVal = $item.attr('data-expanding-list-default')

      $item.find('option').removeAttr('selected')
      if (defaultVal !== undefined) {
        $item.find('option[value="' + defaultVal + '"]').attr('selected', true)
      } else {
        $item.find('option:first').attr('selected', true)
      }
    })

    return $templateForm
  }

  DetailedExpandingListModule.prototype.buildFieldName = function buildFieldName (name, newIndex) {
    // The following expressions are designed to match everything in the following
    // strings apart from the '[0]' index:
    //
    //    application[accreditations_attributes][0][accreditation]
    //
    var nameExpr = /([\w[\]]+)\[0\](\[\w+\])$/

    var matches = name.match(nameExpr)
    var newFieldName = matches[1] + '[' + newIndex + ']' + matches[2]

    return newFieldName
  }

  DetailedExpandingListModule.prototype.buildFieldID = function buildFieldID (id, newIndex) {
    // The following expressions are designed to match everything in the following
    // strings apart from the '[0]' index:
    //
    //    application_accreditations_attributes_0_accreditation
    //
    var idExpr = /([\w[\]]+)_0_(\w+)$/

    var matches = id.match(idExpr)
    var newFieldID = matches[1] + '_' + newIndex + '_' + matches[2]

    return newFieldID
  }

  DetailedExpandingListModule.prototype.getNewIndex = function getNewIndex () {
    var $lastEl = this.$el.find('li:last-of-type')
    var $input = $lastEl.find('input[id]')

    var indexExpr = /[\w[\]]+_(\d+)_\w+$/
    var matches = $input.attr('id').match(indexExpr)

    var lastIndex = parseInt(matches[1])

    return (lastIndex + 1)
  }

  DetailedExpandingListModule.prototype.hasInlineLabels = function hasInlineLabels () {
    var classes = this.$el.attr('class')
    var matches = classes.match(/with-inline-labels/)

    if (matches !== null && matches.length >= 1) {
      return true
    } else {
      return false
    }
  }

  window.ProcurementHub.DetailedExpandingListModule = DetailedExpandingListModule
}())

$(function () {
  $('*[data-module="detailed-expanding-list"]').each(function (i, element) {
    // eslint-disable-next-line no-new
    new window.ProcurementHub.DetailedExpandingListModule({
      $el: $(element)
    })
  })
})
