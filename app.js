const express = require('express')
const app = express()

app.use(express.static('public'))
app.use('/contracts', express.static('build/contracts'))
app.listen(8080)

console.log('Listening on port 8080')