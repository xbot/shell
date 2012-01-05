#!/usr/bin/env python
# -*- encoding: utf-8 -*-
import ftplib,datetime,sys,getopt,tempfile,subprocess,os,types

__version__ = '0.1.0'
__author__ = 'Lenin Lee <lenin.lee@gmail.com>'
__website__ = 'http://0x3f.org'
__editor__ = None

class Torrent(object):
    def __init__(self, timeval, torrent):
        self.time = timeval
        self.torrent = torrent
    def getTime(self, format=None):
        return format is not None and self.time.strftime(format) or self.time
    def getTorrent(self, decode=False):
        return decode is True and self.torrent.decode('gbk') or self.torrent
    def inPastDays(self, past=None):
        '''Check if this torrent is uploaded within $past few days.
        '''
        if past is None: return True
        try: past = int(past)
        except: return False
        if past>=0:
            return (datetime.datetime.now().replace(hour=0,minute=0,second=0)-self.getTime().replace(hour=0,minute=0,second=0)).days <= past
        return False

def FetchTorrentList(session, kwords=None, past=None):
    '''Fetch a list of torrents which match the given conditions ordered by uploaded date
    '''
    rawlst = []
    session.dir(kwords is None and '.' or ("*%s*" % kwords), rawlst.append)
    lst = []
    for l in rawlst:
        parts = l.split()
        if parts[8].endswith('.torrent'):
            timestr = ' '.join(parts[5:8])
            timeval = datetime.datetime.strptime(datetime.datetime.now().strftime('%Y')+' '+timestr, '%Y %b %d %H:%M')
            torrent = Torrent(timeval, parts[8])
            if torrent.inPastDays(past):
                lst.append(torrent)
    lst.sort(lambda x,y: cmp(x.time, y.time))
    return lst

def DownloadTorrent(session, torrent):
    session.retrbinary("RETR %s" % torrent.getTorrent(), open(torrent.getTorrent(True), 'wb').write)

def DownloadTorrents(session, lst):
    for t in lst:
        print >> sys.stdout,'Downloading %s ...' % t.getTorrent(True)
        DownloadTorrent(ftp, t)

def ShowTorrents(lst):
    for t in lst:
        print >> sys.stdout,"%s %s" % (t.getTime("%Y-%m-%d"),t.getTorrent(True).encode(sys.stdin.encoding))

def PickTorrents(lst):
    '''Let user pick torrents to download
    '''
    rawlst = ["%s %s" % (t.getTime("%Y-%m-%d"),t.getTorrent()) for t in lst]
    f = tempfile.NamedTemporaryFile(delete=False)
    f.write("\n".join(rawlst))
    f.close()

    editor,path = GetEditor()
    cmd = "%s %s" % (editor, f.name)
    p = subprocess.Popen(cmd, cwd=path, shell=True, stderr=subprocess.PIPE)
    errmsg = p.communicate()[1]
    if p.returncode != 0:
        print >> sys.stderr, 'Error: %s' % errmsg
        sys.exit(2)

    f = open(f.name)
    rawlst = f.read().split("\n")
    f.close()
    os.unlink(f.name)

    rslt = []
    for t in lst:
        if "%s %s" % (t.getTime("%Y-%m-%d"),t.getTorrent()) in rawlst:
            rslt.append(t)

    while True:
        ipt = raw_input("Start to download the chosen torrents ? (Press A to abort, S to start, R to review.)\n")
        if ipt.upper() == 'A': sys.exit(0)
        elif ipt.upper() in ['S','']: break
        elif ipt.upper() == 'R': rslt = PickTorrents(rslt); break

    return rslt

def GetEditor():
    '''Return a tupple which contains the editor executable with its options and the working directory
    '''
    if __editor__ is not None: os.environ['YYETS_EDITOR'] = __editor__
    editor = os.getenv('YYETS_EDITOR') is not None and os.getenv('YYETS_EDITOR') or os.getenv('EDITOR')
    dirname = ''
    if editor is not None:
        dirname = os.path.dirname(editor)
        editor = os.path.basename(editor)
    return editor,os.path.exists(dirname) and dirname or None

def ShowUsage(error=None):
    if error is not None: print >> sys.stderr, "Error: %s." % str(error)
    print >> sys.stdout,'''
YYeTs.py Version %s
Torrent downloader script for YYeTs.

Usage: yyets.py [OPTS] [ARGS]

Options:
    -h, --help          Print this message.
    -d                  Download torrents.
    -p                  Pick torrents to be downloaded.
    --past=NUM          Limit the range to a NUM of past few days.

Environment Variables:
    __editor__          Acturally, this is an attribute of this script. It identifies
                        the editor which will be used to pick torrents to be downloaded.
                        This attribute has the highest priority above all the following
                        environment variables.
    YYETS_EDITOR        If the attribute __editor__ has been set, this variable will be
                        overridden.
                        This environment variable has higher priority than EDITOR.
    EDITOR              If YYETS_EDITOR has not been set, this variable is used.
''' %  __version__

if __name__ == '__main__':
    # Parse options and arguments
    kwords = None
    download = False
    pick = False
    past = None
    try:
        opts,args = getopt.getopt(sys.argv[1:], "hdp", ["help","past="])
        for opt,arg in opts:
            if opt in ['-h','--help']:
                ShowUsage()
                sys.exit(2)
            elif opt=='-d': download = True
            elif opt=='-p': pick = True
            elif opt=='--past':
                if (type(arg) is types.StringType and arg.isdigit()) or \
                        (type(arg) is types.IntType and arg >= 0):
                    past = int(arg)
                else:
                    raise getopt.GetoptError('Only integers are accepted')
    except getopt.GetoptError,e:
        ShowUsage(e)
        sys.exit(2)

    # Fetch torrents
    ftp = ftplib.FTP('zhongzi.yyets.net')
    ftp.login('anonymous', 'x')
    kwords = '*'.join(args).decode(sys.stdin.encoding).encode('gbk')
    lst = FetchTorrentList(ftp, kwords=kwords, past=past)
    if len(lst) == 0:
        print >> sys.stdout,'No torrents found.'
        sys.exit(0)

    # Download torrents
    if download is True:
        if pick is True:
            lst = PickTorrents(lst)
        DownloadTorrents(ftp, lst)
    else:
        ShowTorrents(lst)

    ftp.quit()
