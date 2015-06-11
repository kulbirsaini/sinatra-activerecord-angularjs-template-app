module.exports = function(grunt){
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    project: {
      name: '<%= pkg.name %>',
      app: 'public',
      assets: 'public/assets',
      css: 'public/assets/css',
      scss: 'public/assets/scss',
      js: 'public/assets/js',
      minjs: 'public/assets/minjs',
      components: 'public/bower_components'
    },
    copy: {
      main: {
        expand: true,
        flatten: true,
        src: '<%= project.components %>/bootstrap-sass/assets/fonts/bootstrap/*.*',
        dest: '<%= project.assets %>/fonts/bootstrap/'
      }
    },
    sass: {
      options: {
        sourcemap: 'none'
      },
      dist: {
        files: [{
          expand: true,
          flatten: true,
          ext: '.css',
          src: ['<%= project.scss %>/*.scss'],
          dest: '<%= project.css %>'
        }]
      }
    },
    cssmin: {
      dist: {
        files: [{
          expand: true,
          flatten: true,
          ext: '.min.css',
          src: '<%= project.css %>/*.css',
          dest: '<%= project.css %>'
        }]
      },
    },
    jshint: {
      all: {
        src: [ 'Gruntfile.js', '<%= project.js %>/*.js' ]
      }
    },
    uglify: {
      options: {
        mangle: 'sort',
      },
      js: {
        files: [{
          '<%= project.minjs %>/application.min.js': '<%= project.js %>/*.js'
        }]
      }
    },
    watch: {
      copy: {
        files: ['<%= project.components %>/bootstrap-sass/assets/fonts/bootstrap/*.*'],
        tasks: ['newer:copy:main']
      },
      sass: {
        files: '<%= project.scss %>/*.scss',
        tasks: ['newer:sass:dist']
      },
      css: {
        files: ['<%= project.css %>/*.css', '!<%= project.css %>/*.min.css'],
        tasks: ['newer:cssmin:dist']
      },
      jshint: {
        files: ['Gruntfile.js', '<%= project.js %>/*.js'],
        tasks: ['newer:jshint:all']
      },
      js: {
        files: '<%= project.js %>/*.js',
        tasks: ['newer:uglify:js']
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-newer');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default',['newer:copy:main', 'newer:sass:dist', 'newer:cssmin:dist', 'newer:jshint:all', 'newer:uglify:js', 'watch']);
};
