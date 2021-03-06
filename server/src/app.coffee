express    = require 'express'
api_v1     = require './scripts/api/v1'
analytics  = require './scripts/analytics'
auth       = require './scripts/stealth/auth'
routes     = require './scripts/routes'
dev        = require './scripts/dev'
utils     = require './scripts/utils'
{resp}     = require './scripts/response'
{cache}    = require './scripts/cache'
# {mongo}    = require './scripts/mongo'

app = module.exports = express.createServer()
cache.init()
# mongo.init()
analytics.init()

# Configuration
app.configure ->
    app.set('views', __dirname + '/views')
    app.set('view engine', 'jade')
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.favicon(__dirname + '/../../client/gen/assets/images/favicon.ico')
    app.use(express.static(__dirname + '/../../client/gen'))

app.configure 'development', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

# Routes
app.get     '/', routes.index
app.get     '/support', routes.support
app.get     '/terms', routes.terms

# API
app.get     '/api/v1/moods', auth.authenticate, api_v1.get_mood
app.post    '/api/v1/moods', auth.authenticate, api_v1.post_mood
app.post    '/api/v1/friends', auth.authenticate, api_v1.change_friends
app.post    '/api/v1/feedback', api_v1.send_feedback
app.get     '/api/v1/dummy', api_v1.populate_dummy

# Private API
app.get     '/verify', utils.verify_ios
app.post    '/api/v1/registerpush', auth.authenticate, api_v1.register_push

# Debugging
app.post     '/dev/err-android', dev.err_android

app.get     '/analytics', auth.authenticate, analytics.get_stats
app.get     '/bot', (req, res) -> resp.success res, 'ok'

app.get     '*', (req, res) -> resp.error res, resp.NOT_FOUND

# Heroku ports or 3000
port = process.env.PORT || 3000
app.listen port, ->
    console.log 'Express server listening on port %d in %s mode at %s', app.address().port, app.settings.env, new Date()
