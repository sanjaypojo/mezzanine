gulp = require 'gulp'
plugins = require('gulp-load-plugins')(camelize:true)

gulp.task 'devClean', () ->
  return gulp.src('public/', read: false)
    .pipe plugins.clean()

gulp.task 'devStyles', () ->
  return gulp.src('styles/style.less')
    .pipe plugins.less()
    .on('error', plugins.util.log)
    .pipe gulp.dest('public/')

# Watch
gulp.task 'watch', () ->
  gulp.watch 'styles/*.less', ['devStyles']

# Default
gulp.task 'default', ['devClean'], () ->
  gulp.start 'devStyles'