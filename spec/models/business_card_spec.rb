# frozen_string_literal: true

# == Schema Information
#
# Table name: business_cards
#
#  id                  :bigint           not null, primary key
#  address             :string
#  code                :string(100)      not null
#  company             :string(100)
#  department          :string(100)
#  email               :string(100)
#  fax                 :string(100)
#  first_name          :string(100)
#  first_name_phonetic :string
#  home_phone          :string(100)
#  job_title           :string(100)
#  last_name           :string(100)
#  last_name_phonetic  :string
#  meeting_date        :datetime
#  mobile_phone        :string(100)
#  notes               :text
#  status              :integer          default("analyzing"), not null
#  website             :string(100)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_business_cards_on_code     (code) UNIQUE
#  index_business_cards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'
require 'google/cloud/vision/v1'

RSpec.describe BusinessCard do
  describe 'validations' do
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:first_name_phonetic).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name_phonetic).is_at_most(100) }
    it { is_expected.to validate_length_of(:job_title).is_at_most(100) }
    it { is_expected.to validate_length_of(:department).is_at_most(100) }
    it { is_expected.to validate_length_of(:website).is_at_most(100) }
    it { is_expected.to validate_length_of(:company).is_at_most(100) }
    it { is_expected.to validate_length_of(:email).is_at_most(100) }
    it { is_expected.to validate_length_of(:mobile_phone).is_at_most(100) }
    it { is_expected.to validate_length_of(:home_phone).is_at_most(100) }
    it { is_expected.to validate_length_of(:fax).is_at_most(100) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:business_card_tags) }
    it { is_expected.to have_many(:tags).through(:business_card_tags) }
    it { is_expected.to have_one_attached(:front_image) }
    it { is_expected.to have_one_attached(:back_image) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(analyzing: 0, analyzed: 1, failed: 2).with_prefix }
  end

  describe 'callbacks' do
    describe 'before_create' do
      describe '#generate_code' do
        let(:business_card) { create(:business_card) }

        it 'generates code' do
          expect(business_card.code).to be_present
        end
      end
    end
  end

  describe 'methods' do
    describe '#analyze!' do
      context 'when OpenAI API returns a valid JSON string' do
        let(:business_card) { create(:business_card) }

        before do
          # Mock the Google Cloud Vision API response
          image_annotator_mock = instance_double(Google::Cloud::Vision::V1::ImageAnnotator::Client)
          allow(Google::Cloud::Vision).to receive(:image_annotator).and_return(image_annotator_mock)

          allow(image_annotator_mock).to receive(:text_detection).and_return(
            OpenStruct.new(
              responses: [
                OpenStruct.new(
                  full_text_annotation:
                    OpenStruct.new(
                      text: '
                      金融システム事業部
                      システムインテグレーションビジネス部
                      開発担当 シニア・スペシャリスト
                      山下大輔
                      株式会社NTTデータ九州
                      〒812-0011 福岡市博多区博多駅前1-17-21
                      NTTDATA博多駅前ビル
                      Tel: 092-475-5109 Fax: 092-475-5190
                      E-mail: yamashitadib@nttdate-kyushu.co.jp
                      www.nttdata-kyushu.co.jp
                      NTT Data
                      Trusted Global Innovator
                      福岡県
                      子育て応援宣言
                      登録マーク
                      '
                    )
                ),
                OpenStruct.new(
                  full_text_annotation:
                    OpenStruct.new(
                      text: '
                      金融システム事業部
                      システムインテグレーションビジネス部
                      開発担当 シニア・スペシャリスト
                      山下大輔
                      株式会社NTTデータ九州
                      〒812-0011 福岡市博多区博多駅前1-17-21
                      NTTDATA博多駅前ビル
                      Tel: 092-475-5109 Fax: 092-475-5190
                      E-mail: yamashitadib@nttdate-kyushu.co.jp
                      www.nttdata-kyushu.co.jp
                      NTT Data
                      Trusted Global Innovator
                      福岡県
                      子育て応援宣言
                      登録マーク
                      '
                    )
                )
              ]
            )
          )

          # Mock the OpenAI API response
          openai_client_mock = instance_double(OpenAI::Client)
          allow(OpenAI::Client).to receive(:new).and_return(openai_client_mock)

          allow(openai_client_mock).to receive(:chat).and_return(
            OpenStruct.new(
              choices: [
                OpenStruct.new(
                  message: OpenStruct.new(
                    content: '
                    {
                      "first_name": "大輔",
                      "last_name": "山下",
                      "first_name_phonetic": "ダイスケ",
                      "last_name_phonetic": "ヤマシタ",
                      "company": "株式会社NTTデータ九州",
                      "job_title": "システムインテグレーションビジネス部 開発担当 シニア・スペシャリスト",
                      "department": "金融システム事業部",
                      "website": "www.nttdata-kyushu.co.jp",
                      "address": "〒812-0011 福岡市博多区博多駅前1-17-21 NTTDATA博多駅前ビル",
                      "email": "yamashitadib@nttdate-kyushu.co.jp",
                      "mobile_phone": "092-475-5109",
                      "home_phone": null,
                      "fax": "092-475-5190"
                    }
                    '
                  )
                )
              ]
            )
          )
        end

        it 'sets the business card information' do
          business_card.analyze!

          business_card.reload

          expect(business_card.status).to eq('analyzed')
          expect(business_card.first_name).to eq('大輔')
          expect(business_card.last_name).to eq('山下')
          expect(business_card.first_name_phonetic).to eq('ダイスケ')
          expect(business_card.last_name_phonetic).to eq('ヤマシタ')
          expect(business_card.company).to eq('株式会社NTTデータ九州')
          expect(business_card.job_title).to eq('システムインテグレーションビジネス部 開発担当 シニア・スペシャリスト')
          expect(business_card.department).to eq('金融システム事業部')
          expect(business_card.website).to eq('www.nttdata-kyushu.co.jp')
          expect(business_card.address).to eq('〒812-0011 福岡市博多区博多駅前1-17-21 NTTDATA博多駅前ビル')
          expect(business_card.email).to eq('yamashitadib@nttdate-kyushu.co.jp')
          expect(business_card.mobile_phone).to eq('092-475-5109')
          expect(business_card.home_phone).to be_nil
          expect(business_card.fax).to eq('092-475-5190')
        end
      end

      context 'when OpenAI API returns an invalid JSON string' do
        let(:business_card) { create(:business_card, :with_analyzing_state) }

        before do
          # Mock the Google Cloud Vision API response
          image_annotator_mock = instance_double(Google::Cloud::Vision::V1::ImageAnnotator::Client)
          allow(Google::Cloud::Vision).to receive(:image_annotator).and_return(image_annotator_mock)

          allow(image_annotator_mock).to receive(:text_detection).and_return(
            OpenStruct.new(
              responses: [
                OpenStruct.new(
                  full_text_annotation:
                    OpenStruct.new(
                      text: '
                      金融システム事業部
                      システムインテグレーションビジネス部
                      開発担当 シニア・スペシャリスト
                      山下大輔
                      株式会社NTTデータ九州
                      〒812-0011 福岡市博多区博多駅前1-17-21
                      NTTDATA博多駅前ビル
                      Tel: 092-475-5109 Fax: 092-475-5190
                      E-mail: yamashitadib@nttdate-kyushu.co.jp
                      www.nttdata-kyushu.co.jp
                      NTT Data
                      Trusted Global Innovator
                      福岡県
                      子育て応援宣言
                      登録マーク
                      '
                    )
                ),
                OpenStruct.new(
                  full_text_annotation:
                    OpenStruct.new(
                      text: '
                      金融システム事業部
                      システムインテグレーションビジネス部
                      開発担当 シニア・スペシャリスト
                      山下大輔
                      株式会社NTTデータ九州
                      〒812-0011 福岡市博多区博多駅前1-17-21
                      NTTDATA博多駅前ビル
                      Tel: 092-475-5109 Fax: 092-475-5190
                      E-mail: yamashitadib@nttdate-kyushu.co.jp
                      www.nttdata-kyushu.co.jp
                      NTT Data
                      Trusted Global Innovator
                      福岡県
                      子育て応援宣言
                      登録マーク
                      '
                    )
                )
              ]
            )
          )

          # Mock the OpenAI API response
          openai_client_mock = instance_double(OpenAI::Client)
          allow(OpenAI::Client).to receive(:new).and_return(openai_client_mock)

          allow(openai_client_mock).to receive(:chat).and_return(
            OpenStruct.new(
              choices: [
                OpenStruct.new(
                  message: OpenStruct.new(
                    content: '
                    Invalid JSON string
                    '
                  )
                )
              ]
            )
          )
        end

        it 'sets the business card information' do
          business_card.analyze!

          business_card.reload

          expect(business_card.status).to eq('failed')
          expect(business_card.first_name).to be_nil
          expect(business_card.last_name).to be_nil
          expect(business_card.first_name_phonetic).to be_nil
          expect(business_card.last_name_phonetic).to be_nil
          expect(business_card.company).to be_nil
          expect(business_card.job_title).to be_nil
          expect(business_card.department).to be_nil
          expect(business_card.website).to be_nil
          expect(business_card.address).to be_nil
          expect(business_card.email).to be_nil
          expect(business_card.mobile_phone).to be_nil
          expect(business_card.home_phone).to be_nil
          expect(business_card.fax).to be_nil
        end
      end
    end
  end
end
