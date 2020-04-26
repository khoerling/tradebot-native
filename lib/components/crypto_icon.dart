import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CryptoIcon extends StatelessWidget {
  const CryptoIcon({Key key, this.name, this.onPressed}) : super(key: key);
  final name;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
        assets.containsKey(name)
            ? "assets/cryptofont/SVG/${name}.svg"
            : "assets/cryptofont/SVG/btc.svg",
        color: Colors.white,
        height: 50,
        width: 50);
  }
}

Map assets = {
  '1337': true,
  '42': true,
  '888': true,
  'abt': true,
  'aby': true,
  'abyss': true,
  'ac3': true,
  'acat': true,
  'acc': true,
  'ace': true,
  'act': true,
  'ada': true,
  'adb': true,
  'adc': true,
  'adh': true,
  'adi': true,
  'adst': true,
  'adt': true,
  'adx': true,
  'ae': true,
  'aeon': true,
  'aerm': true,
  'agi': true,
  'aht': true,
  'ai': true,
  'aib': true,
  'aid': true,
  'aidoc': true,
  'aion': true,
  'air': true,
  'ait': true,
  'aix': true,
  'algo': true,
  'alis': true,
  'alqo': true,
  'alt': true,
  'amb': true,
  'amlt': true,
  'amm': true,
  'amn': true,
  'amp': true,
  'ams': true,
  'anc': true,
  'ant': true,
  'aph': true,
  'apis': true,
  'appc': true,
  'apr': true,
  'arc': true,
  'arct': true,
  'ardr': true,
  'arg': true,
  'ark': true,
  'arn': true,
  'art': true,
  'ary': true,
  'ast': true,
  'astro': true,
  'atb': true,
  'atc': true,
  'atl': true,
  'atm': true,
  'atmc': true,
  'atn': true,
  'atom': true,
  'ats': true,
  'atx': true,
  'auc': true,
  'aur': true,
  'aura': true,
  'avt': true,
  'axp': true,
  'b2b': true,
  'banca': true,
  'bank': true,
  'bat': true,
  'bax': true,
  'bay': true,
  'bbi': true,
  'bbn': true,
  'bbo': true,
  'bbp': true,
  'bbr': true,
  'bcc': true,
  'bcd': true,
  'bcn': true,
  'bco': true,
  'bcpt': true,
  'bdg': true,
  'bdl': true,
  'bee': true,
  'bela': true,
  'berry': true,
  'bet': true,
  'betr': true,
  'bez': true,
  'bft': true,
  'bigup': true,
  'birds': true,
  'bis': true,
  'bitb': true,
  'bitg': true,
  'bits': true,
  'bitz': true,
  'bix': true,
  'bkx': true,
  'blc': true,
  'blitz': true,
  'blk': true,
  'bln': true,
  'block': true,
  'blt': true,
  'blu': true,
  'blue': true,
  'blz': true,
  'blz2': true,
  'bmc': true,
  'bmh': true,
  'bnb': true,
  'bnk': true,
  'bnt': true,
  'bnty': true,
  'boat': true,
  'bon': true,
  'bos': true,
  'bot': true,
  'bpt': true,
  'bqx': true,
  'brat': true,
  'brd': true,
  'bsd': true,
  'bsm': true,
  'bta': true,
  'btc': true,
  'btca': true,
  'btcd': true,
  'btcp': true,
  'btdx': true,
  'bte': true,
  'btg': true,
  'btm': true,
  'btm2': true,
  'bto': true,
  'btrn': true,
  'bts': true,
  'btx': true,
  'burst': true,
  'busd': true,
  'buzz': true,
  'bwk': true,
  'byc': true,
  'c20': true,
  'can': true,
  'candy': true,
  'cann': true,
  'capp': true,
  'carbon': true,
  'cas': true,
  'cat': true,
  'cat2': true,
  'caz': true,
  'cbc': true,
  'cbt': true,
  'cbx': true,
  'ccrb': true,
  'cdn': true,
  'cdt': true,
  'ceek': true,
  'cennz': true,
  'cfi': true,
  'chc': true,
  'chp': true,
  'chsb': true,
  'chx': true,
  'cjt': true,
  'ckb': true,
  'cl': true,
  'clam': true,
  'cln': true,
  'clo': true,
  'cloak': true,
  'clr': true,
  'cmpco': true,
  'cms': true,
  'cmt': true,
  'cnd': true,
  'cnet': true,
  'cnn': true,
  'cnx': true,
  'coal': true,
  'cob': true,
  'colx': true,
  'con': true,
  'coss': true,
  'cov': true,
  'coval': true,
  'cpc': true,
  'cpc2': true,
  'cpn': true,
  'cpx': true,
  'cpy': true,
  'crave': true,
  'crb': true,
  'crc': true,
  'cre': true,
  'crea': true,
  'cred': true,
  'credo': true,
  'crm': true,
  'crop': true,
  'crpt': true,
  'crw': true,
  'cs': true,
  'csc': true,
  'csno': true,
  'ctr': true,
  'ctxc': true,
  'cure': true,
  'cv': true,
  'cvc': true,
  'cvcoin': true,
  'cvt': true,
  'cxo': true,
  'dadi': true,
  'dai': true,
  'dan': true,
  'dasc': true,
  'dash': true,
  'dat': true,
  'data': true,
  'datx': true,
  'dax': true,
  'daxx': true,
  'day': true,
  'dbc': true,
  'dbet': true,
  'dcn': true,
  'dcr': true,
  'dct': true,
  'dcy': true,
  'ddd': true,
  'ddf': true,
  'deb': true,
  'dent': true,
  'dero': true,
  'deus': true,
  'dev': true,
  'dew': true,
  'dft': true,
  'dgb': true,
  'dgd': true,
  'dgpt': true,
  'dgtx': true,
  'dice': true,
  'dim': true,
  'dime': true,
  'divx': true,
  'dix': true,
  'dlisk': true,
  'dlt': true,
  'dmb': true,
  'dmd': true,
  'dml': true,
  'dmt': true,
  'dna': true,
  'dnr': true,
  'dnt': true,
  'dock': true,
  'doge': true,
  'dp': true,
  'dpy': true,
  'drgn': true,
  'drop': true,
  'drpu': true,
  'drt': true,
  'drxne': true,
  'dsh': true,
  'dsr': true,
  'dta': true,
  'dtb': true,
  'dth': true,
  'dtr': true,
  'dtrc': true,
  'duo': true,
  'dxt': true,
  'earth': true,
  'ebtc': true,
  'eca': true,
  'ecash': true,
  'ecc': true,
  'ecob': true,
  'edg': true,
  'edo': true,
  'edr': true,
  'edt': true,
  'edu': true,
  'efl': true,
  'efx': true,
  'efyt': true,
  'egc': true,
  'egcc': true,
  'eko': true,
  'ekt': true,
  'el': true,
  'ela': true,
  'elec': true,
  'elf': true,
  'elix': true,
  'ella': true,
  'eltcoin': true,
  'emb': true,
  'emc': true,
  'emc2': true,
  'eng': true,
  'enj': true,
  'enrg': true,
  'ent': true,
  'eos': true,
  'eosdac': true,
  'epc': true,
  'eql': true,
  'eqt': true,
  'erc': true,
  'erc20': true,
  'ero': true,
  'esp': true,
  'esz': true,
  'etbs': true,
  'etc': true,
  'eth': true,
  'etn': true,
  'etp': true,
  'ett': true,
  'etz': true,
  'euc': true,
  'evc': true,
  'eve': true,
  'evn': true,
  'evr': true,
  'evx': true,
  'excl': true,
  'exy': true,
  'face': true,
  'fair': true,
  'fct': true,
  'fdx': true,
  'fdz': true,
  'fil': true,
  'fjc': true,
  'flash': true,
  'flixx': true,
  'flo': true,
  'fluz': true,
  'fnd': true,
  'for': true,
  'fota': true,
  'frec': true,
  'frst': true,
  'fsn': true,
  'fst': true,
  'ft': true,
  'ftc': true,
  'ftt': true,
  'ftx': true,
  'fuel': true,
  'fun': true,
  'func': true,
  'fxt': true,
  'fyn': true,
  'game': true,
  'gat': true,
  'gb': true,
  'gbx': true,
  'gbyte': true,
  'gcc': true,
  'gcs': true,
  'gen': true,
  'gene': true,
  'get': true,
  'getx': true,
  'gin': true,
  'gla': true,
  'gno': true,
  'gnt': true,
  'gnx': true,
  'go': true,
  'god': true,
  'golf': true,
  'golos': true,
  'good': true,
  'grc': true,
  'grft': true,
  'grid': true,
  'grlc': true,
  'grmd': true,
  'grn': true,
  'grs': true,
  'gsc': true,
  'gtc': true,
  'gto': true,
  'guess': true,
  'gup': true,
  'gvt': true,
  'gxs': true,
  'hac': true,
  'hade': true,
  'hat': true,
  'hav': true,
  'hbar': true,
  'hbc': true,
  'heat': true,
  'her': true,
  'hero': true,
  'hgt': true,
  'hire': true,
  'hkn': true,
  'hlc': true,
  'hmc': true,
  'hmq': true,
  'hot': true,
  'hot2': true,
  'hpb': true,
  'hpc': true,
  'hqx': true,
  'hsr': true,
  'hst': true,
  'ht': true,
  'huc': true,
  'hur': true,
  'hush': true,
  'hvn': true,
  'hxx': true,
  'hydro': true,
  'ic': true,
  'icn': true,
  'icon': true,
  'icx': true,
  'idh': true,
  'idt': true,
  'idxm': true,
  'ieth': true,
  'ift': true,
  'ignis': true,
  'iht': true,
  'iic': true,
  'inc': true,
  'incnt': true,
  'ind': true,
  'infx': true,
  'ing': true,
  'ink': true,
  'inn': true,
  'inpay': true,
  'ins': true,
  'insn': true,
  'instar': true,
  'insur': true,
  'int': true,
  'inv': true,
  'inxt': true,
  'ioc': true,
  'ion': true,
  'iop': true,
  'iost': true,
  'iota': true,
  'iotx': true,
  'ipl': true,
  'iqt': true,
  'isl': true,
  'itc': true,
  'itns': true,
  'itt': true,
  'ivy': true,
  'ixc': true,
  'ixt': true,
  'j8t': true,
  'jc': true,
  'jet': true,
  'jew': true,
  'jnt': true,
  'karma': true,
  'kb3': true,
  'kbr': true,
  'kcs': true,
  'key': true,
  'key2': true,
  'kick': true,
  'kin': true,
  'kln': true,
  'kmd': true,
  'knc': true,
  'kobo': true,
  'kore': true,
  'krb': true,
  'krm': true,
  'krone': true,
  'kurt': true,
  'la': true,
  'lala': true,
  'latx': true,
  'lba': true,
  'lbc': true,
  'lbtc': true,
  'lcc': true,
  'ldc': true,
  'lend': true,
  'leo': true,
  'let': true,
  'lev': true,
  'lgd': true,
  'lgo': true,
  'linda': true,
  'link': true,
  'linx': true,
  'live': true,
  'lkk': true,
  'lmc': true,
  'lnc': true,
  'lnd': true,
  'loc': true,
  'loci': true,
  'log': true,
  'loki': true,
  'loom': true,
  'lrc': true,
  'lsk': true,
  'ltc': true,
  'lun': true,
  'lux': true,
  'lwf': true,
  'lyl': true,
  'lym': true,
  'mag': true,
  'maid': true,
  'man': true,
  'mana': true,
  'max': true,
  'mbrs': true,
  'mcap': true,
  'mco': true,
  'mda': true,
  'mdc': true,
  'mds': true,
  'mdt': true,
  'mec': true,
  'med': true,
  'medic': true,
  'meet': true,
  'mer': true,
  'mfg': true,
  'mgo': true,
  'minex': true,
  'mint': true,
  'mith': true,
  'mitx': true,
  'mkr': true,
  'mln': true,
  'mne': true,
  'mntp': true,
  'mnx': true,
  'mnx2': true,
  'moac': true,
  'mobi': true,
  'mod': true,
  'mof': true,
  'moin': true,
  'mojo': true,
  'mona': true,
  'moon': true,
  'morph': true,
  'mot': true,
  'mrk': true,
  'mrq': true,
  'mscn': true,
  'msp': true,
  'msr': true,
  'mtc': true,
  'mth': true,
  'mtl': true,
  'mtn': true,
  'mtx': true,
  'mue': true,
  'muse': true,
  'music': true,
  'mvc': true,
  'mwat': true,
  'myb': true,
  'myst': true,
  'nanj': true,
  'nano': true,
  'nanox': true,
  'nas': true,
  'nav': true,
  'navi': true,
  'nbai': true,
  'ncash': true,
  'nct': true,
  'nebl': true,
  'neo': true,
  'neos': true,
  'net': true,
  'neu': true,
  'newb': true,
  'nexo': true,
  'ngc': true,
  'nio': true,
  'nkn': true,
  'nlc2': true,
  'nlg': true,
  'nlx': true,
  'nmc': true,
  'nmr': true,
  'nms': true,
  'nobl': true,
  'nper': true,
  'npxs': true,
  'nrg': true,
  'nsr': true,
  'ntk': true,
  'ntrn': true,
  'nuko': true,
  'nuls': true,
  'nvst': true,
  'nxs': true,
  'nxt': true,
  'nyan': true,
  'oax': true,
  'obits': true,
  'oc': true,
  'occ': true,
  'ocn': true,
  'oct': true,
  'ode': true,
  'odn': true,
  'ok': true,
  'okb': true,
  'omg': true,
  'omni': true,
  'omx': true,
  'onion': true,
  'ont': true,
  'onx': true,
  'oot': true,
  'opc': true,
  'open': true,
  'opt': true,
  'ore': true,
  'ori': true,
  'orme': true,
  'ost': true,
  'otn': true,
  'otx': true,
  'oxy': true,
  'pac': true,
  'pai': true,
  'pak': true,
  'pal': true,
  'pareto': true,
  'part': true,
  'pasc': true,
  'pasl': true,
  'pat': true,
  'pay': true,
  'payx': true,
  'pbl': true,
  'pbt': true,
  'pcl': true,
  'pcn': true,
  'pfr': true,
  'pho': true,
  'phr': true,
  'phs': true,
  'ping': true,
  'pink': true,
  'pirl': true,
  'pivx': true,
  'pix': true,
  'pkc': true,
  'pkt': true,
  'plan': true,
  'play': true,
  'plbt': true,
  'plc': true,
  'plr': true,
  'plu': true,
  'plx': true,
  'pmnt': true,
  'pnt': true,
  'poa': true,
  'poe': true,
  'polis': true,
  'poll': true,
  'poly': true,
  'pos': true,
  'post': true,
  'posw': true,
  'pot': true,
  'powr': true,
  'ppc': true,
  'ppp': true,
  'ppt': true,
  'ppy': true,
  'pra': true,
  'pre': true,
  'prg': true,
  'prl': true,
  'pro': true,
  'proc': true,
  'prs': true,
  'pst': true,
  'ptc': true,
  'ptoy': true,
  'pura': true,
  'pure': true,
  'pwr': true,
  'pylnt': true,
  'pzm': true,
  'qash': true,
  'qau': true,
  'qbic': true,
  'qbt': true,
  'qkc': true,
  'qlc': true,
  'qlr': true,
  'qora': true,
  'qrk': true,
  'qsp': true,
  'qtum': true,
  'qun': true,
  'qvt': true,
  'qwark': true,
  'r': true,
  'rads': true,
  'rain': true,
  'rbt': true,
  'rby': true,
  'rcn': true,
  'rdd': true,
  'rdn': true,
  'real': true,
  'rebl': true,
  'red': true,
  'ree': true,
  'ref': true,
  'rem': true,
  'ren': true,
  'rep': true,
  'repo': true,
  'req': true,
  'rex': true,
  'rfr': true,
  'rhoc': true,
  'ric': true,
  'rise': true,
  'rkt': true,
  'rlc': true,
  'rmt': true,
  'rnt': true,
  'rntb': true,
  'rpx': true,
  'ruff': true,
  'rup': true,
  'rvn': true,
  'rvt': true,
  'safex': true,
  'saga': true,
  'sai': true,
  'sal': true,
  'salt': true,
  'san': true,
  'sbtc': true,
  'scl': true,
  'scs': true,
  'sct': true,
  'sdc': true,
  'sdrn': true,
  'seele': true,
  'sen': true,
  'senc': true,
  'senc2': true,
  'send': true,
  'sense': true,
  'sent': true,
  'seq': true,
  'seth': true,
  'sexc': true,
  'sfc': true,
  'sgcc': true,
  'sgn': true,
  'sgr': true,
  'shift': true,
  'ship': true,
  'shl': true,
  'shorty': true,
  'shp': true,
  'sia': true,
  'sib': true,
  'sigt': true,
  'skb': true,
  'skin': true,
  'skm': true,
  'sky': true,
  'slg': true,
  'slr': true,
  'sls': true,
  'slt': true,
  'smart': true,
  'smc': true,
  'sms': true,
  'smt': true,
  'snc': true,
  'sngls': true,
  'snm': true,
  'sntr': true,
  'snx': true,
  'soar': true,
  'soc': true,
  'soil': true,
  'soul': true,
  'spank': true,
  'spd': true,
  'spd2': true,
  'spf': true,
  'sphtx': true,
  'spk': true,
  'spr': true,
  'sprts': true,
  'src': true,
  'srcoin': true,
  'srn': true,
  'ss': true,
  'ssp': true,
  'sss': true,
  'sta': true,
  'stac': true,
  'stak': true,
  'start': true,
  'stc': true,
  'steem': true,
  'stn': true,
  'stn2': true,
  'storj': true,
  'storm': true,
  'stq': true,
  'strat': true,
  'strc': true,
  'stv': true,
  'stx': true,
  'sub': true,
  'sumo': true,
  'super': true,
  'sur': true,
  'svh': true,
  'swftc': true,
  'swift': true,
  'swm': true,
  'swt': true,
  'swtc': true,
  'sxdt': true,
  'sys': true,
  'taas': true,
  'tau': true,
  'tbar': true,
  'tbx': true,
  'tct': true,
  'tdx': true,
  'tel': true,
  'ten': true,
  'tes': true,
  'tfd': true,
  'thc': true,
  'theta': true,
  'tie': true,
  'tig': true,
  'time': true,
  'tio': true,
  'tips': true,
  'tit': true,
  'tix': true,
  'tka': true,
  'tkn': true,
  'tkr': true,
  'tks': true,
  'tky': true,
  'tmt': true,
  'tnb': true,
  'tnc': true,
  'tns': true,
  'tnt': true,
  'tok': true,
  'tokc': true,
  'tomo': true,
  'tpay': true,
  'trac': true,
  'trak': true,
  'trc': true,
  'trct': true,
  'trig': true,
  'trst': true,
  'true': true,
  'trump': true,
  'trust': true,
  'trx': true,
  'tsl': true,
  'ttt': true,
  'turbo': true,
  'tusd': true,
  'tx': true,
  'tzc': true,
  'ubq': true,
  'ubt': true,
  'ubtc': true,
  'ucash': true,
  'ufo': true,
  'ufr': true,
  'ugc': true,
  'uip': true,
  'uis': true,
  'ukg': true,
  'unb': true,
  'uni': true,
  'unify': true,
  'unit': true,
  'unity': true,
  'uno': true,
  'up': true,
  'uqc': true,
  'usdt': true,
  'usnbt': true,
  'utc': true,
  'utk': true,
  'utnp': true,
  'uuu': true,
  'v': true,
  'vee': true,
  'ven': true,
  'veri': true,
  'via': true,
  'vib': true,
  'vibe': true,
  'vit': true,
  'viu': true,
  'vivo': true,
  'vme': true,
  'voise': true,
  'vrc': true,
  'vrm': true,
  'vrs': true,
  'vsl': true,
  'vsx': true,
  'vtc': true,
  'vtr': true,
  'vzt': true,
  'wabi': true,
  'wan': true,
  'wand': true,
  'warp': true,
  'waves': true,
  'wax': true,
  'wct': true,
  'wdc': true,
  'wgr': true,
  'whl': true,
  'wild': true,
  'wings': true,
  'wish': true,
  'wpr': true,
  'wrc': true,
  'wtc': true,
  'xas': true,
  'xaur': true,
  'xbl': true,
  'xbp': true,
  'xbts': true,
  'xby': true,
  'xcp': true,
  'xcpo': true,
  'xct': true,
  'xcxt': true,
  'xdce': true,
  'xdn': true,
  'xel': true,
  'xem': true,
  'xes': true,
  'xgox': true,
  'xhv': true,
  'xin': true,
  'xios': true,
  'xjo': true,
  'xlm': true,
  'xlr': true,
  'xmcc': true,
  'xmg': true,
  'xmo': true,
  'xmr': true,
  'xmx': true,
  'xmy': true,
  'xnk': true,
  'xnn': true,
  'xp': true,
  'xpa': true,
  'xpd': true,
  'xpm': true,
  'xptx': true,
  'xrh': true,
  'xrl': true,
  'xrp': true,
  'xsh': true,
  'xsn': true,
  'xspec': true,
  'xst': true,
  'xstc': true,
  'xtl': true,
  'xto': true,
  'xtz': true,
  'xvg': true,
  'xyo': true,
  'xzc': true,
  'yee': true,
  'yoc': true,
  'yoyow': true,
  'ytn': true,
  'zap': true,
  'zb': true,
  'zcl': true,
  'zco': true,
  'zec': true,
  'zen': true,
  'zeni': true,
  'zeph': true,
  'zer': true,
  'zet': true,
  'zil': true,
  'zipt': true,
  'zla': true,
  'zny': true,
  'zoi': true,
  'zpt': true,
  'zrx': true,
  'zsc': true,
  'zzc': true,
};
