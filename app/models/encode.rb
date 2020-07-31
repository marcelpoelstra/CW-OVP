class Encode < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_one_attached :thumbnail
  validates :title, presence: true
  validates :file, presence: true, blob: { content_type: :video } # supported options: :image, :audio, :video, :text
  scope :published, -> { where(published: true) }
  scope :by_date, -> { order('id DESC') }
  before_create :default_values
  def default_values
    self.started_at ||= Time.now
    self.published ||= true
    self.completed ||= false
  end
  def file_path
    yyyy = self.created_at.strftime("%Y")
    mm = self.created_at.strftime("%m")
    dd = self.created_at.strftime("%d")
    id = self.id
    "hls/#{yyyy}/#{mm}/#{dd}/#{id}"
  end
  def send_message message, log, percentage = "0%"
    log << message.to_s+"\n"
    ActionCable.server.broadcast "encode_channel", encode_id: self.id, content: message.to_s+"\n", percentage: percentage, encode: self
    Rails.logger.debug "percentage: #{percentage}"
  end
  def percentage now_time = nil, total_time = nil
    if now_time.nil? or total_time.nil?
      percentage = "0%"
    else
      percentage = (self.convert_to_second(now_time) / self.convert_to_second(total_time) * 100).truncate(2)
      percentage = 100 if percentage > 100
      percentage.to_s + "%"
    end
  end
  def convert_to_second time
    (Time.parse(time).to_i - Date.today.to_time.to_i).to_f
  end
  def rand_second total_time = nil
    if total_time.nil?
      return "00:00:00.000"
    end
    end_second = convert_to_second total_time
    prng = Random.new
    seconds = prng.rand(0..end_second.floor)
    Time.at(seconds).utc.strftime("%H:%M:%S.%L")
  end
  def extract_thumbnail runtime, temp_file_full_path, file_full_path
    ss = self.rand_second(runtime)
    thumbnail_cmd = `sh app/encoding/thumbnail.sh #{temp_file_full_path} #{ss} #{file_full_path}`
    Rails.logger.debug "thumbnail_cmd : #{thumbnail_cmd}"
    thumbnail_path = "#{file_full_path}/thumbnail.png"
    Rails.logger.debug "thumbnail path : #{thumbnail_path}"
    self.thumbnail.attach(io: File.open(thumbnail_path), filename: "#{self.id}_thumbnail.png", content_type: "image/png")
  end
end
