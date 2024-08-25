# frozen_string_literal: true

require 'rails_helper'
require 'google/cloud/vision/v1'
require 'ostruct'

RSpec.describe BusinessCards::AnalyzeBusinessCard do
  describe '#call' do
    context 'when OpenAI API returns a valid JSON string' do
      let(:business_card) { create(:business_card, :analyzing) }

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
        described_class.new(business_card: business_card, language_hints: ['en']).call

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
      let(:business_card) { create(:business_card, :analyzing) }

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
        described_class.new(business_card: business_card, language_hints: ['en']).call

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
