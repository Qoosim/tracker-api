require 'rails_helper'

RSpec.describe 'Exercises API', type: :request do
  # initialize test data 
  let!(:user) { create(:user) }
  let!(:exercises) { create_list(:exercise, 10, user_id: user.id) }
  let(:exercise_id) { exercises.first.id }
   # authorize request
   let(:headers) { valid_headers }

  # Test suite for GET /exercises
  describe 'GET /exercises' do
    # make HTTP get request before each example
    before { get '/exercises' , params: {}, headers: headers }

    it 'returns exercises' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /exercises/:id
  describe 'GET /exercises/:id' do
    before { get "/exercises/#{exercise_id}", params: {}, headers: headers }

    context 'when the record exists' do
      it 'returns the exercise' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(exercise_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:exercise_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Exercise/)
      end
    end
  end

  # Test suite for POST /exercises
  describe 'POST /exercises' do
    # valid payload
    let(:valid_attributes) { { name: 'Squats', user_id: user.id.to_s }.to_json }

    context 'when the request is valid' do
      before { post '/exercises', params: valid_attributes, headers: headers }

      it 'creates a exercise' do
        expect(json['name']).to eq('Squats')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) { { name: nil }.to_json }
      before { post '/exercises', params: invalid_attributes, headers: headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['message'])
          .to match(/Validation failed: Name can't be blank/)
      end
    end
  end

  # Test suite for PUT /exercises/:id
  describe 'PUT /exercises/:id' do
    let(:valid_attributes) { { name: 'Push ups' }.to_json }

    context 'when the record exists' do
      before { put "/exercises/#{exercise_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /exercises/:id
  describe 'DELETE /exercises/:id' do
    before { delete "/exercises/#{exercise_id}", params: {}, headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end