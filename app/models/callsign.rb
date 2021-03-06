class Callsign < ActiveRecord::Base
  include FriendlyId
  friendly_id :name, use: :slugged

  STATUSES = %w(pending approved available reserved temporary).freeze

  audited
  has_associated_audits

  attr_accessible :name, :note, :status

  has_many :assignments, autosave: true, dependent: :destroy,
    class_name: 'CallsignAssignment'
  has_many :people, through: :assignments

  validates :name, presence: true, length: {in: 1..32}
  validates_uniqueness_of :name, case_sensitive: false, allow_blank: false
  validates :status, inclusion: {in: STATUSES}

  self.per_page = 100

  def current_assignee
    assigned_to = assignments.current.first
    assigned_to && assigned_to.person
  end

  def to_s
    name
  end
end
