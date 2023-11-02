<p align="center">
  <a href="https://matomeishi.vercel.app">
    <img src="https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/c0840e59-db43-4681-ae7b-31a04dc4bc55/d7eqdvw-4e97ac92-e4b9-4498-9655-e4d612eb478b.png/v1/fill/w_1192,h_670/random_logo_by_criticl_d7eqdvw-pre.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9OTAwIiwicGF0aCI6IlwvZlwvYzA4NDBlNTktZGI0My00NjgxLWFlN2ItMzFhMDRkYzRiYzU1XC9kN2VxZHZ3LTRlOTdhYzkyLWU0YjktNDQ5OC05NjU1LWU0ZDYxMmViNDc4Yi5wbmciLCJ3aWR0aCI6Ijw9MTYwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.X991O1jF5lTNZbbEoHEfoo6nlHEihBMHMIm5-uBCXcU" width="60" />
  </a>
</p>
<h1 align="center">
  matomeishi.vercel.app
</h1>

[![Maintainability](https://api.codeclimate.com/v1/badges/7e812d56f9b763cc731c/maintainability)](https://codeclimate.com/github/tonystrawberry/matomeishi-rails.jp/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/7e812d56f9b763cc731c/test_coverage)](https://codeclimate.com/github/tonystrawberry/matomeishi-rails.jp/test_coverage)

matomeishi is a versatile web-based platform accessible on both desktop and mobile browsers 🖥

It offers a seamless solution for effortlessly **managing business cards**. Users can easily scan and store their business cards, utilizing **Optical Character Recognition (OCR)** technology to **extract and identify text information** from the cards 🤖

This feature enables **automatic population of relevant fields**, reducing manual data entry 📝

The application also includes a **robust search functionality**, allowing users to quickly retrieve cards using free-text queries or associated tags 🔍

With this tool, individuals **no longer need to juggle physical business cards**. They can simply upload them to the application and dispose of the physical copies, streamlining their networking and contact management experience 🤩

<a href="https://matomeishi.vercel.app" target="_blank">**matomeishi.vercel.app**</a>

## 📚 Technologies
```
Rails API 7
PostgreSQL 13
Google Cloud Vision API
Google Cloud Storage API
Firebase Authentication
OpenAPI
```

- 🚀 **matomeishi (front-end)** is implemented with **NextJS 13** and deployed with <a href="https://github.com/tonystrawberry/matomeishi-next.jp" target="_blank">**Vercel**</a>

- 🖥 **matomeishi (back-end)** is implemented with <a href="https://github.com/tonystrawberry/matomeishi-rails.jp" target="_blank">**Rails API**</a> and deployed and hosted with <a href="https://dashboard.render.com/web/srv-ckug543amefc7388himg" target="_blank">**Render**</a>

- 💾 The **database** is hosted on <a href="https://supabase.com/dashboard/project/bivrcuxracfevdbpzpln" target="_blank">**Supabase**</a>

- 📁 The **files** (images) are stored on <a href="https://console.cloud.google.com/storage/browser?project=matomeishi-401514&prefix=&forceOnBucketsSortingFiltering=true" target="_blank">**Google Cloud Storage**</a>

## 🛠 Local development

1. Set the necessary environment variables in the `.env` file.

```
OPENAI_API_KEY=
GOOGLE_CLOUD_STORAGE_PROJECT_ID=
BUGSNAG_API_KEY=

# Only for production environment because we use local database for development
SUPABASE_DATABASE_HOST=
SUPABASE_DATABASE_PASSWORD=
```

2. Put the `google-cloud-storage-credentials.json` and `google-cloud-vision-credentials.json` files in the root directory. These corresponds to the credentials for Google Cloud Storage and Google Cloud Vision API respectively.

Obtainable via the following steps:
- Create a project on Google Cloud Platform
- Enable Google Cloud Storage and Google Cloud Vision API
- Create a service account for each API
- Download the credentials file for each API (Keys tab of the service account page)

3. Install PostgreSQL in your local environment and run it.

4. Run the following commands to install the libraries and setup the database (one-time only).
```
$ bundle install
$ rails db:create db:migrate
$ rails db:seed_fu # Only if you want to seed the database with sample data
```

4. Run the following command to start the server.

```
$ rails s
```

## ⚙️ Deployment

The application is deployed to production with <a href="https://dashboard.render.com/web/srv-ckug543amefc7388himg" target="_blank">**Render**</a> every time a pull request is merged into the `main` branch or a commit is pushed to the `main` branch.

URL of the API is <a href="https://matomeishi.onrender.com/" target="_blank">**https://matomeishi.onrender.com/**</a>

## 💾 Access to production environment

- **Database** migration
```
SUPABASE_DATABASE_HOST="" SUPABASE_DATABASE_PASSWORD="" RAILS_ENV="production" rails db:migrate
```

## ⚠️ Error reporting

- <a href="https://app.bugsnag.com/tonystrawberry/matomeishi-rails-dot-jp/overview" target="_blank">**Bugsnag**</a> is used to monitor the errors in production environment.

## 📝 Memo to myself

- [] Make use of rbs for type checking
