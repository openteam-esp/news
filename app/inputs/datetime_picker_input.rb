class DatetimePickerInput < Formtastic::Inputs::StringInput
  def input_html_options
    super.merge(:class => "datetime_picker", :value => object.send(method) ? I18n.l(object.send(method)) : nil)
  end
end
