[4mffuf[24m(1)                                User Commands                               [4mffuf[24m(1)

[1mNAME[0m
       [1mffuf [22m- Fast web fuzzer written in Go

[1mSYNOPSIS[0m
            [1mffuf [22m[[1moptions[22m]

[1mDESCRIPTION[0m
       [1mffuf  [22mis  a  fest web fuzzer written in Go that allows typical directory discovery,
       virtual host discovery (without DNS records) and GET and POST parameter fuzzing.

[1mOPTIONS[0m
       HTTP OPTIONS

              [1m-H     [22mHeader "Name: Value", separated by colon. Multiple [1m-H [22mflags  are  ac‐
                     cepted.

              [1m-X     [22mHTTP method to use (default: GET)

              [1m-b     [22mCookie data "NAME1=VALUE1; NAME2=VALUE2" for copy as curl functional‐
                     ity.

              [1m-d     [22mPOST data

              [1m-ignore-body[0m
                     Do not fetch the response content. (default: false)

              [1m-r     [22mFollow redirects (default: false)

              [1m-recursion[0m
                     Scan recursively. Only FUZZ keyword is supported, and URL ([1m-u[22m) has to
                     end in it. (default: false) [1m-recursion-depth [22mMaximum recursion depth.
                     (default: false)

              [1m-recursion-depth[0m
                     Maximum recursion depth. (default: 0)

              [1m-recursion-strategy[0m
                     Recursion  strategy:  "default" for a redirect based, and "greedy" to
                     recurse on all matches (default: default)

              [1m-replay-proxy[0m
                     Replay matched requests using this proxy.

              [1m-sni   [22mTarget TLS SNI, does not support FUZZ keyword.

              [1m-timeout[0m
                     HTTP request timeout in seconds. (default: 10)

              [1m-u     [22mTarget URL

              [1m-x     [22mHTTP Proxy URL

       GENERAL OPTIONS

              [1m-V     [22mShow version information. (default: false)

              [1m-ac    [22mAutomatically calibrate filtering options (default: false)

              [1m-acc   [22mCustom auto-calibration string. Can be used multiple  times.  Implies
                     [1m-ac[0m

              [1m-c     [22mColorize output. (default: false)

              [1m-maxtime[0m
                     Maximum running time in seconds. (default: 0)

              [1m-maxtime-job[0m
                     Maximum running time in seconds per job. (default: 0)

              [1m-noninteractive[0m
                     Disable the interactive console functionality (default: false)

              [1m-p     [22mSeconds  of 'delay' between requests, or a range of random delay. For
                     example "0.1" or "0.1-2.0"

              [1m-rate  [22mRate of requests per second (default: 0)

              [1m-s     [22mDo not print additional information (silent mode) (default: false)

              [1m-sa    [22mStop on all error cases. Implies [1m-sf [22mand [1m-se[22m. (default: false)

              [1m-se    [22mStop on spurious errors (default: false)

              [1m-sf    [22mStop when > 95% of responses return 403 Forbidden (default: false)

              [1m-t     [22mNumber of concurrent threads. (default: 40)

              [1m-v     [22mVerbose output, printing full URL and redirect location (if any) with
                     the results. (default: false)

       MATCHER OPTIONS

              [1m-mc    [22mMatch  HTTP  status  codes,  or  "all"  for   everything.   (default:
                     200,204,301,302,307,401,403)

              [1m-ml    [22mMatch amount of lines in response

              [1m-mr    [22mMatch regexp

              [1m-ms    [22mMatch HTTP response size

              [1m-mt    [22mMatch  how  many  milliseconds  to  the  first  response byte, either
                     greater or less than. EG: >100 or <100

              [1m-mw    [22mMatch amount of words in response

       FILTER OPTIONS

              [1m-fc    [22mFilter HTTP status codes from response. Comma separated list of codes
                     and ranges

              [1m-fl    [22mFilter by amount of lines in response. Comma separated list  of  line
                     counts and ranges

              [1m-fr    [22mFilter regexp

              [1m-fs    [22mFilter HTTP response size. Comma separated list of sizes and ranges

              [1m-ft    [22mFilter  by  number of milliseconds to the first response byte, either
                     greater or less than. EG: >100 or <100

              [1m-fw    [22mFilter by amount of words in response. Comma separated list  of  word
                     counts and ranges

       INPUT OPTIONS

              [1m-D     [22mDirSearch  wordlist  compatibility  mode. Used in conjunction with [1m-e[0m
                     flag. (default: false)

              [1m-e     [22mComma separated list of extensions. Extends FUZZ keyword.

              [1m-ic    [22mIgnore wordlist comments (default: false)

              [1m-input-cmd[0m
                     Command producing the input. [1m--input-num [22mis required when using  this
                     input method. Overrides [1m-w[22m.

              [1m-input-num[0m
                     Number  of inputs to test. Used in conjunction with [1m--input-cmd[22m. (de‐
                     fault: 100)

              [1m-input-shell[0m
                     Shell to be used for running command

              [1m-mode  [22mMulti-wordlist operation mode. Available modes:  clusterbomb,  pitch‐
                     fork (default: clusterbomb)

              [1m-request[0m
                     File containing the raw http request

              [1m-request-proto[0m
                     Protocol to use along with raw request (default: https)

              [1m-w     [22mWordlist  file  path  and  (optional) keyword separated by colon. eg.
                     '/path/to/wordlist:KEYWORD'

       OUTPUT OPTIONS

              [1m-debug-log[0m
                     Write all of the internal logging to the specified file.

              [1m-o     [22mWrite output to file

              [1m-od    [22mDirectory path to store matched results to.

              [1m-of    [22mOutput file format. Available formats: json, ejson,  html,  md,  csv,
                     ecsv (or, 'all' for all formats) (default: json)

              [1m-or    [22mDon't  create  the  output  file  if  we don't have results (default:
                     false)

       INTERACTIVE MODE
              available commands:

              [1mfc [value][0m
                     (re)configure status code filter.

              [1mfl [value][0m
                     (re)configure line count filter.

              [1mfw [value][0m
                     (re)configure word count filter.

              [1mfs [value][0m
                     (re)configure size filter.

              [1mqueueshow[0m
                     show recursive job queue.

              [1mqueuedel [number][0m
                     delete a recursion job in the queue.

              [1mqueueskip[0m
                     advance to the next queued recursion job.

              [1mrestart[0m
                     restart and resume the current ffuf job.

              [1mresume [22mresume current ffuf job (or: ENTER).

              [1mshow   [22mshow results for the current job.

              [1msavejson [filename][0m
                     save current matches to a file.

              [1mhelp   [22mshow help menu.

[1mEXAMPLE USAGE[0m
       Fuzz file paths from wordlist.txt, match all responses but filter  out  those  with
       content-size 42.  Colored, verbose output.

              [1mffuf -w [22mwordlist.txt [1m-u [22mhttps://example.org/FUZZ [1m-mc [22mall [1m-fs [22m42 [1m-c -v[0m

       Fuzz Host-header, match HTTP 200 responses.

              [1mffuf -w [22mhosts.txt [1m-u [22mhttps://example.org/ [1m-H [22m"Host: FUZZ" [1m-mc [22m200

       Fuzz POST JSON data. Match all responses not containing text "error".

              [1mffuf -w [22mentries.txt [1m-u [22mhttps://example.org/ [1m-X [22mPOST [1m-H [22m"Content-Type: appli‐
              cation/json" [1m-d [22m'{"name": "FUZZ", "anotherkey": "anothervalue"}' [1m-fr [22m"error"

       Fuzz  multiple  locations.  Match only responses reflecting the value of "VAL" key‐
       word. Colored.

              [1mffuf -w [22mparams.txt:PARAM [1m-w [22mvalues.txt:VAL [1m-u [22mhttps://example.org/?PARAM=VAL
              [1m-mr [22m"VAL" [1m-c[0m

       More information and examples: https://github.com/[1mffuf[22m/[1mffuf[0m

[1mNOTE[0m
       In [1mINTERACTIVE MODE[22m, filters can be reconfigured, queue  managed  and  the  current
       state saved to disk.

       When  (re)configuring  the filters, they get applied posthumously and all the false
       positive matches from memory that would have been filtered out by the  newly  added
       filters get deleted.

       The new state of matches can be printed out with a command show that will print out
       all the matches as like they would have been found by ffuf.

       As  "negative" matches are not stored to memory, relaxing the filters cannot unfor‐
       tunately bring back the lost matches. For this kind of scenario, the user  is  able
       to  use the command restart, which resets the state and starts the current job from
       the beginning.

[1mAUTHOR[0m
       This manual page was written based on the author's README by  Pedro  Loami  Barbosa
       dos Santos <pedro@loami.eng.br> for the Debian project (but may be used by others).

ffuf 1.4.0                               Mar 2022                                  [4mffuf[24m(1)
