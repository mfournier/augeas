(* Parsing yum's config files *)
module Yum =
  autoload xfm

(************************************************************************
 * INI File settings
 *************************************************************************)

let comment  = IniFile.comment "#" "#"
let sep      = IniFile.sep "=" "="
let empty    = Util.empty
let eol      = IniFile.eol


(************************************************************************
 *                        ENTRY
 *************************************************************************)

let list_entry (list_key:string)  =
  let list_value = store /[^# \t\r\n,][^ \t\r\n,]*[^# \t\r\n,]|[^# \t\r\n,]/ in
  let list_sep = del /([ \t]*(,[ \t]*|\r?\n[ \t]+))|[ \t]+/ "\n\t" in
  [ key list_key . sep . Sep.opt_space . list_value ]
  . (list_sep . Build.opt_list [ label list_key . list_value ] list_sep)?
  . eol

let entry_re = IniFile.entry_re - ("baseurl" | "gpgkey")

let entry       = IniFile.entry entry_re sep comment
                | empty

let entries = entry*
            | entry* . list_entry "baseurl" . entry* . (list_entry "gpgkey" . entry*)?
            | entry* . list_entry "gpgkey" . entry* . (list_entry "baseurl" . entry*)?



(***********************************************************************a
 *                         TITLE
 *************************************************************************)
let title       = IniFile.title IniFile.record_re
let record      = [ title . entries ]


(************************************************************************
 *                         LENS & FILTER
 *************************************************************************)
let lns    = (empty | comment)* . record*

  let filter = (incl "/etc/yum.conf")
      . (incl "/etc/yum.repos.d/*.repo")
      . (incl "/etc/yum/yum-cron*.conf") 
      . (incl "/etc/yum/pluginconf.d/*")
      . (excl "/etc/yum/pluginconf.d/versionlock.list")
      . Util.stdexcl

  let xfm = transform lns filter

(* Local Variables: *)
(* mode: caml       *)
(* End:             *)
