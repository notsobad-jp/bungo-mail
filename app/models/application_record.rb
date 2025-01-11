class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def human_attribute_enum(attr_name, locale = I18n.locale)
    self.class.human_attribute_enum_value(attr_name, self[attr_name], locale)
  end

  def self.human_attribute_enum_value(attr_name, value, locale = I18n.locale)
    # モデル別のカラムで翻訳が定義されてるか探して、なければ例外を投げる
    I18n.t!("#{attr_name.to_s.pluralize}.#{value}", scope: [:activerecord, :attributes, self.model_name.i18n_key], locale: locale)
  rescue StandardError
    # モデル別のカラムで定義されてなかった場合、共通カラムの翻訳を探す
    I18n.t("#{attr_name.to_s.pluralize}.#{value}", scope: [:attributes], locale: locale)
  end
end
