require! <[gulp gulp-concat gulp-livereload gulp-bower gulp-bower-files gulp-filter node-static tiny-lr]>
gutil             = require \gulp-util
livescript        = require \gulp-livescript
stylus            = require \gulp-stylus
jade              = require \gulp-jade
livereload-server = tiny-lr!
livereload        = -> gulp-livereload livereload-server

path =
  src:   './src'
  build: '.'

gulp.task \bower -> gulp-bower!

gulp.task \js:vendor <[bower]> ->
  gulp-bower-files!
  .pipe gulp-filter (.path is /\.js$/)
  .pipe gulp-concat 'vendor.js'
  .pipe gulp.dest "#{path.build}/js"

gulp.task \js:app ->
  gulp.src do
    * "#{path.src}/**/*.ls"
    ...
  .pipe gulp-concat 'main.ls'
  .pipe livescript!
  .pipe gulp.dest "#{path.build}/js"
  .pipe livereload!

gulp.task \css:vendor ->
  gulp-bower-files!
  .pipe gulp-filter (.path is /\.css$/)
  .pipe gulp-concat 'vendor.css'
  .pipe gulp.dest "#{path.build}/css"

gulp.task \css:app ->
  gulp.src do
    * "#{path.src}/**/*.styl"
    ...
  .pipe gulp-concat 'style.styl'
  .pipe stylus use: <[nib]>
  .pipe gulp.dest "#{path.build}/css"
  .pipe livereload!

gulp.task \html ->
  gulp.src "#{path.src}/*.jade"
  .pipe jade!
  .pipe gulp.dest path.build
  .pipe livereload!

gulp.task \build <[js:vendor js:app css:vendor css:app html]>

gulp.task \server (next) ->
  server = new node-static.Server path.build
  port = 8888
  require \http .createServer (req, res) !->
    req.addListener(\end -> server.serve req, res)resume!
  .listen port, !->
    gutil.log "Server listening on port: #{gutil.colors.magenta port}"
    next!

gulp.task \watch ->
  gulp.watch 'bower.json'             <[js:vendor css:vendor]>
  gulp.watch "#{path.src}/**/*.ls"    <[js:app]>
  gulp.watch "#{path.src}/**/*.styl"  <[css:app]>
  gulp.watch "#{path.src}/*.jade"     <[html]>

gulp.task \livereload ->
  port = 35729
  livereload-server.listen port, ->
    return gulp.log it if it
    gutil.log "LiveReload listening on port: #{gutil.colors.magenta port}"

gulp.task \default <[build watch server livereload]>
