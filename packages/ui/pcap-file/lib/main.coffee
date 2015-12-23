$ = require('jquery')
fs = require('fs')
remote = require('remote')
Menu = remote.require('menu')
MenuItem = remote.require('menu-item')
config = require('./config')

class MainMenu
  activate: ->
    return
    action = (name) ->
      ->
        dripcap.action.emit name

    @menu = (menu, e) ->
      file = new Menu
      file.append new MenuItem label: 'New Window', accelerator: 'CmdOrCtrl+Shift+N', click: action 'Core: New Window'
      file.append new MenuItem label: 'Close Window', accelerator: 'CmdOrCtrl+Shift+W', click: action 'Core: Close Window'
      file.append new MenuItem type: 'separator'
      file.append new MenuItem label: 'Quit', accelerator: 'CmdOrCtrl+Q', click: action 'Core: Quit'

      edit = new Menu
      if process.platform == 'darwin'
        edit.append new MenuItem label: 'Cut', accelerator: 'Cmd+X', selector: 'cut:'
        edit.append new MenuItem label: 'Copy', accelerator: 'Cmd+C', selector: 'copy:'
        edit.append new MenuItem label: 'Paste', accelerator: 'Cmd+V', selector: 'paste:'
        edit.append new MenuItem label: 'Select All', accelerator: 'Cmd+A', selector: 'selectAll:'
      else
        contents = remote.getCurrentWebContents()
        edit.append new MenuItem label: 'Cut', accelerator: 'Ctrl+X', click: -> contents.cut()
        edit.append new MenuItem label: 'Copy', accelerator: 'Ctrl+C', click: -> contents.copy()
        edit.append new MenuItem label: 'Paste', accelerator: 'Ctrl+V', click: -> contents.paste()
        edit.append new MenuItem label: 'Select All', accelerator: 'Ctrl+A', click: -> contents.selectAll()
      edit.append new MenuItem type: 'separator'
      edit.append new MenuItem label: 'Preferences', accelerator: 'CmdOrCtrl+,', click: action 'Core: Preferences'

      capturing = dripcap.pubsub.get 'Core: Capturing Status' ? false
      session = new Menu
      session.append new MenuItem label: 'New Session', accelerator: 'CmdOrCtrl+N', click: action 'Core: New Session'
      session.append new MenuItem type: 'separator'
      session.append new MenuItem label: 'Start', enabled: !capturing, click: action 'Core: Start Sessions'
      session.append new MenuItem label: 'Stop', enabled: capturing, click: action 'Core: Stop Sessions'

      developer = new Menu
      developer.append new MenuItem label: 'Toggle DevTools', accelerator: 'CmdOrCtrl+Shift+I', click: action 'Core: Toggle DevTools'
      developer.append new MenuItem label: 'Open User Directory', click: action 'Core: Open User Directory'

      help = new Menu
      help.append new MenuItem label: 'Open Website', click: action 'Core: Open Dripcap Website'
      help.append new MenuItem label: 'Show License', click: action 'Core: Show License'
      help.append new MenuItem type: 'separator'
      help.append new MenuItem label: 'Version ' + config, enabled: false

      menu.append new MenuItem label: 'File', submenu: file, type: 'submenu'
      menu.append new MenuItem label: 'Edit', submenu: edit, type: 'submenu'
      menu.append new MenuItem label: 'Session', submenu: session, type: 'submenu'
      menu.append new MenuItem label: 'Developer', submenu: developer, type: 'submenu'
      menu

    @helpMenu = (menu, e) ->
      help = new Menu
      help.append new MenuItem label: 'Open Website', click: action 'Core: Open Dripcap Website'
      help.append new MenuItem label: 'Show License', click: action 'Core: Show License'
      help.append new MenuItem type: 'separator'
      help.append new MenuItem label: 'Version ' + config, enabled: false

      menu.append new MenuItem label: 'Help', submenu: help, type: 'submenu', role: 'help'
      menu

    dripcap.menu.register 'MainMenu: MainMenu', @menu
    dripcap.menu.register 'MainMenu: MainMenu', @helpMenu, -10

    dripcap.theme.sub 'registoryUpdated', ->
      dripcap.menu.updateMainMenu()

    dripcap.pubsub.sub 'Core: Capturing Status', ->
      dripcap.menu.updateMainMenu()

  deactivate: ->
    dripcap.menu.unregisterMain 'File', @menu

module.exports = MainMenu