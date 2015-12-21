# Helps a site user understand XTraktr
class HelpArticle
  include Mongoid::Document
  include Mongoid::Timestamps

  #############################
  # Note: The code in this model is organized slightly differently.
  # The fields are presented with their related code one at a time,
  # including callbacks, validations, index, etc. All scopes are at
  # the bottom.
  #############################

  #############################
  # title: The title of the help article

  field :title, type: String, localize: true
  index(title: 1)

  attr_accessible :title,
                  :title_translations

  def validates_presence_of_title_for_default_language
    default_language = I18n.default_locale.to_s

    return if title_translations[default_language].present?

    errors.add(:base,
               I18n.t('errors.messages.translation_default_lang',
                      field_name: self.class.human_attribute_name('title'),
                      language: Language.get_name(default_language),
                      msg: I18n.t('errors.messages.blank')))
  end
  validate :validates_presence_of_title_for_default_language

  def set_empty_title_to_nil
    title_translations.keys.each do |key|
      title_translations[key] = nil if title_translations[key].empty?
    end
  end
  before_save :set_empty_title_to_nil

  #############################
  # article_type : General categorization of the article

  field :article_type_id, type: Integer, default: 1
  index(article_type_id: 1)

  attr_accessible :article_type_id

  ARTICLE_TYPES = {
    how_to: 1,
    tip: 2
  }

  def article_type_symbol
    ARTICLE_TYPES.keys[ARTICLE_TYPES.values.index(article_type_id)]
  end

  def self.translate_article_type(article_type_symbol)
    I18n.t("mongoid.attributes.help_article.article_type_values.#{article_type_symbol}")
  end

  def article_type
    HelpArticle.translate_article_type(article_type_symbol)
  end

  def self.article_types_and_ids
    types_and_ids = []
    ARTICLE_TYPES.keys.each do |article_type_key|
      type_id = ARTICLE_TYPES[article_type_key]
      translated_type_key = translate_article_type(article_type_key)
      types_and_ids << [translated_type_key, type_id]
    end

    types_and_ids
  end

  validates_presence_of :article_type_id
  validates :article_type_id, inclusion: { in: ARTICLE_TYPES.values }

  #############################
  # sort_order : Determines the primary order of the articles

  field :sort_order, type: Integer, default: 1
  index(sort_order: 1)

  attr_accessible :sort_order

  validates_presence_of :sort_order

  #############################
  # public : Whether the article is accessible to the public

  field :public, type: Boolean, default: false
  index(public: 1)

  attr_accessible :public

  validates_presence_of :public

  #############################
  # public_at : The date the article was made public

  field :public_at, type: Date
  index(public: 1)

  attr_accessible :public_at

  def update_public_at
    return unless public_changed?

    if public
      self[:public_at] = Date.today
    else
      self[:public_at] = nil
    end
  end
  before_save :update_public_at

  #############################
  # content : The main content of the article

  field :content, type: String, localize: true
  index(content: 1)

  attr_accessible :content,
                  :content_translations

  def validates_presence_of_content_for_default_language
    default_language = I18n.default_locale.to_s

    return if content_translations[default_language].present?

    errors.add(:base,
               I18n.t('errors.messages.translation_default_lang',
                      field_name: self.class.human_attribute_name('content'),
                      language: Language.get_name(default_language),
                      msg: I18n.t('errors.messages.blank')))
  end
  validate :validates_presence_of_content_for_default_language

  #############################
  # Has many help categories through help_category_mappers

  attr_accessible :help_category_ids
  attr_accessor :help_category_ids

  has_many :help_category_mappers, dependent: :destroy do
    def help_category_ids
      pluck(:help_category_id)
    end
  end

  accepts_nested_attributes_for :help_category_mappers,
                                reject_if: :all_blank,
                                allow_destroy: true

  # this is used in the form to set the categories
  def set_help_category_ids
    self.help_category_ids = help_category_mappers.help_category_ids
    true
  end
  after_initialize :set_help_category_ids

  #############################
  # Scopes

  def self.sorted
    order_by([[:sort_order, :asc], [:title, :asc]])
  end

  def self.is_public
    where(public: true)
  end

  def self.by_article_type(article_type)
    desired_article_type_id = ARTICLE_TYPES[article_type]
    where(article_type_id: desired_article_type_id)
  end
end