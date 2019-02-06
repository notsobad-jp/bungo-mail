# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  token             :string           not null
#  user_id           :bigint(8)        not null
#  title             :string           not null
#  description       :text
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  default           :boolean          default(FALSE), not null
#

class Channel < ApplicationRecord
  belongs_to :user
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true
  validates :description, presence: { message: '：チャネルを公開する場合は「チャネルの説明」の入力も必須です' }, if: proc { |c| c.public? }

  before_create do
    self.token = SecureRandom.hex(10)
  end

  before_save do
    user.channels.update_all(default: false) if default
  end

  def add_book(book)
    channel_books.create_with(index: max_index + 1).find_or_create_by(book_id: book.id)
  end

  def max_index
    channel_books.maximum(:index) || 0
  end

  # いま一番進んでる配信で配信中のbook_index。これより前の本は編集しちゃだめ。
  def latest_index
    sql = "SELECT MAX(channel_books.index) FROM subscriptions JOIN channel_books ON (subscriptions.channel_id = channel_books.channel_id AND subscriptions.current_book_id = channel_books.book_id) WHERE subscriptions.channel_id=#{id}"
    ActiveRecord::Base.connection.select_value(sql) || 0 # 購読者なしのときはnilが来るので代わりに0を返す
  end
end
