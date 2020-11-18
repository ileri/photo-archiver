# photo-archiver

Status: [![Workflow Status](https://github.com/ileri/photo-archiver/workflows/Ruby/badge.svg)](https://github.com/ileri/photo-archiver/actions)

A simple manager and archiver for photos.

## Pre-Requirements

This application is written in `Ruby` language and optionally uses `bundle`
helper.

If you will use resizing feature, you
[need to have installed](https://github.com/minimagick/minimagick#requirements)
ImageMagick or GraphicsMagick in your system.

## Installation

To use photo-archiver in you system, you need to install depended gems to
your system. To install necessary gems with bundler helper:

*If you want to install test environment, remove `--without test` parameters.*

```sh
bundle install --without test
```

If bundler completed successfully, and pre-requirements are installed,
installation is completed. You can configure and start to use application.

```sh
bundle exec ruby archiver.rb
```

## Configuration

This simple archiver uses configs from a YAML file.

Edit `archiver_config.yml` file to make configuration.
Configuration  setting are described below.

**Warning:** Never set `src_dir` same with `dst_dir` or `dst_dir` as a subdir
of `src_dir`.  This will cause to recurrence!

```yaml
archiver:
  src_dir: "./photos"           # Source directory. This directory is listening for new files.         ( type: string  )
  dst_dir: "./archived_photos"  # Destination directory. Archived photos will store in this directory. ( type: string  )
  resize: true                  # Apply resizing to photos.                                            ( type: boolean )
  resize_x: "640"               # If apply resizing, width of resized photo.                           ( type: integer )
  resize_y: "480"               # If apply resizing, height of resized photo.                          ( type: integer )
  keep_ratio: true              # If apply resizing, keep the oroginal ratio or not.                   ( type: boolean )
  logging: true                 # Enable logging for image archiving.                                  ( type: boolean )
  auto_delete: true             # Automatically delete not archived photos on init.                    ( type: boolean )
  delete_days: 1                # If auto_delete enabled, delete older than N days photos.             ( type: integer )
  archive_original: true        # Archive original photo                                               ( type: boolean )
  archive_resized: true         # Archive resized photo                                                ( type: boolean )
  original_prefix: ''           # Prefix for archived original image                                   ( type: string  )
  original_postfix: '_original' # Postfix for archived original image                                  ( type: string  )
  run_on_init: true             # Run archiving for source directory on application init               ( type: boolean )
```

## Supported Operating Systems

This application is written in **Linux** ( Debian ) environment and fully
compatible with Unix-like systems ( includes **macOS X** too ).

Application also fully compatible with **Windows** operating systems.
