----[[version: 20131016.00]]
---[[by lostangel 20100528]]
---[[edit 20101117]]
---[[edit 20110402 for new return struct]]
---[[edit 20110625 for new bilibili.tv]]
---[[edit 20110704 for new acfun.tv]]
---[[edit 20110705 for acfun.tv batch]]
---[[note: this version must run with acfunlocalizer 2.600+]]
---[[edit 20120817 fro new bilibili.kankanews.com ]]
---[[edit 20121028 for new bilibili.smgbb.cn]]
---[[edit 20121119 for ifeng]]
---[[edit 20130204 for cntv]]
---[[edit 20130423 for iqiyi]]
---[[edit 20130512 for sohu]]
---[[edit 20130714 for letv]]
---[[edit 20130714 for letv multi-P]]


require "luascript/sitelist/acfun"
require "luascript/sitelist/bilibili"
require "luascript/sitelist/mikufans"
require "luascript/sitelist/youku"
require "luascript/sitelist/qqvideo"
require "luascript/sitelist/nicovideo"
require "luascript/sitelist/tudou"
require "luascript/sitelist/sina"
require "luascript/sitelist/ifeng"
require "luascript/sitelist/cntv"
require "luascript/sitelist/iqiyi"
require "luascript/sitelist/sohu"
require "luascript/sitelist/letv"
require "luascript/customadd"
--require "your site parse script"

--[[
tbl_re is a table indexed by string from "0" ,"1",...to "n"(tbl_re has n+1 elements).
every element is also a table, which can defined by:
element {
	"acfpv" 		: 	int			// acfun player version whose value can be found in function 'getACFPV' in lalib.lua
	"descriptor" 	: 	string		// dlfile name
	"subxmlurl"		:	table		// this is a table indexed by string from "0", "1",...to "n", every element is a string (real subxml file url) can be {} for a null group.
	"realurlnum"	:	int			// the following table"realurls" elements num
	"realurls"		:	table		// this is a table indexed by string from "0", "1",...to "n", every element is a string (real downloading url)
	"oriurl"		:	string		// orignial url
}

str_url:		string // is oriurl above
str_tmpfile:	string // can be used(w+r) latter, which is a temp file
str_servername:	string // only when acfun downloading it is used.
pDlg:			int	   // a pointer to a internal C++ object, which can be used in following function.

these api is provided for debug:
sShowMessage(pDlg, string); //which can show string in newtask dlg.
dbgMessage(string); //popup a MessageBox to show the string. when the msgbox popuped, the script is suspended until u close the msgbox.
string utf8_to_lua(utf8string); //transfer utf8 string to lua string.

there are also 2 funtions for retreive files from internet:
dlFile(filesavepath, fileurl); //example can be found in every sitelist script
postdlFile(filesavepath, posturl, postdata, postheader); // example can be found in nicovideo.lua.
]]
function getTaskAttribute ( str_url, str_tmpfile ,str_servername, pDlg)
	local tbl_re = {};

	--local tmpstr = encrypt("abcdefgh");
	--dbgMessage(tmpstr);
	--tmpstr = decrypt(tmpstr);
	--dbgMessage(tmpstr);

	if string.find(str_url, "acfun.tv", 1, true)~=nil or string.find(str_url, "acfun.cn", 1, true)~=nil or string.find(str_url, --[["220.170.79.109"]]"124.228.254.229", 1, true)~=nil or string.find(str_url, str_servername, 1, true)~=nil
	then
		return getTaskAttribute_acfun(str_url, str_tmpfile, str_servername, pDlg);
	end

	if string.find(str_url, "bilibili.smgbb.cn", 1, true)~=nil or string.find(str_url, "bilibili.kankanews.com", 1, true)~=nil or string.find(str_url, "bilibili.tv", 1, true)~=nil or string.find(str_url, "bilibili.us", 1, true)~=nil
	then
		return getTaskAttribute_bilibili(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "dm.mikufans.cn", 1, true)~=nil or string.find(str_url, "danmaku.us", 1, true)~=nil
	then
		return getTaskAttribute_mikufans(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "youku.com", 1, true)~=nil
	then
		return getTaskAttribute_youku(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "video.qq.com", 1, true)~=nil
	then
		return getTaskAttribute_qq(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "nicovideo.jp", 1, true)~=nil
	then
		return getTaskAttribute_nico(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "tudou.com", 1, true)~=nil
	then
		return getTaskAttribute_tudou(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "video.sina.com.cn", 1, true)~=nil
	then
		return getTaskAttribute_sina(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "v.ifeng.com", 1, true)~=nil
	then
		return getTaskAttribute_ifeng(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "cntv.cn", 1, true)~=nil
	then
		return getTaskAttribute_cntv(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "iqiyi.com", 1, true)~=nil
	then
		return getTaskAttribute_iqiyi(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "sohu.com", 1, true)~=nil
	then
		return getTaskAttribute_sohu(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "letv.com", 1, true)~=nil
	then
		return getTaskAttribute_letv(str_url, str_tmpfile, pDlg);
	end
	--if ..add more site parser here
	return getTaskAttribute_Custom(str_url, str_tmpfile, str_servername, pDlg);

	--finally url cannot be recognized.
	--sShowMessage(pDlg, "Ŀǰ����ַ����֧�ֽ���������½����ű������б�д��");
	--return tbl_re;
end

function getTaskAttributeBatch ( str_url, str_tmpfile, str_servername, pDlg)
	local tbl_re = {};
	if string.find(str_url, "acfun.tv", 1, true)~=nil or string.find(str_url, "acfun.cn", 1, true)~=nil or string.find(str_url, "124.228.254.229", 1, true)~=nil or string.find(str_url, str_servername, 1, true)~=nil
	then
		return getTaskAttributeBatch_acfun(str_url, str_tmpfile, str_servername, pDlg);
	end

	if string.find(str_url, "bilibili.smgbb.cn", 1, true)~=nil or string.find(str_url, "bilibili.kankanews.com", 1, true)~=nil or string.find(str_url, "bilibili.tv", 1, true)~=nil or string.find(str_url, "bilibili.us", 1, true)~=nil
	then
		return getTaskAttributeBatch_bilibili(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "dm.mikufans.cn", 1, true)~=nil  or string.find(str_url, "danmaku.us", 1, true)~=nil
	then
		return getTaskAttributeBatch_mikufans(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "youku.com", 1, true)~=nil
	then
		return getTaskAttributeBatch_youku(str_url, str_tmpfile, pDlg);
	end

	if string.find(str_url, "letv.com", 1, true)~=nil
	then
		return getTaskAttributeBatch_letv(str_url, str_tmpfile, pDlg);
	end

	--elseif ..add more site parser here

	return getTaskAttributeBatch_Custom(str_url, str_tmpfile, str_servername, pDlg);
	--finally url cannot be recognized.
	--sShowMessage(pDlg, "Ŀǰ����ַ����֧����������������½����ű������б�д��");
	--return tbl_re;
end

