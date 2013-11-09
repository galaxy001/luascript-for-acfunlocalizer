---[[by lostangel 20100723]]
---[[edit 20110104]]

--[[
this script is to expand functions of main add .
if you use your custom script to support downloading contents from other sites,
you can add your own script into this file.



]]

function getTaskAttribute_Custom(str_url, str_tmpfile, str_servername, pDlg)
	local tbl_re = {};
	--if string.find(str_url, "youku.com", 1, true)~=nil
	--then
	--	return getTaskAttribute_youku(str_url, str_tmpfile, pDlg);
	--end
	--[[you can add some scripts like above]]
	--add script here
	--dbgMessage("test .mp3");

	--if string.find(str_url, "mp3", 1, true)~=nil
	--then
		local _,_,str_descriptor = string.find(str_url,
			"http://.+/(.+)");

		dbgMessage(str_descriptor);
		local tbl_realurls = {};
		tbl_realurls["0"] = str_url;--"http://ww2.sinaimg.cn/bmiddle/bd19d62ejw1e9tu2dp8gxj20go0dc3yu.jpg";--
		--tbl_realurls["1"] = "http://imgfast.dmzj.com/w/%E4%BC%AA%E6%81%8B/%E7%AC%AC95%E8%AF%9D/0%20%282%29.jpg";
		--dbgMessage(tbl_realurls["1"]);
		--sShowMessage(pDlg, tbl_realurls["1"]);

		local tbl_subxmlurls = {};
		--tbl_subxmlurls["0"] = "http://www.baidu.com/index.php";

		local tbl_ta = {};
		tbl_ta["acfpv"] = 1;
		tbl_ta["descriptor"] = str_descriptor;
		tbl_ta["subxmlurl"] = tbl_subxmlurls;
		tbl_ta["realurlnum"] = 1;
		tbl_ta["realurls"] = tbl_realurls;
		tbl_ta["oriurl"] = str_url;

		local tbl_resig = {};
		tbl_resig["0"] = tbl_ta;

		return tbl_resig;
	--end


	--end add

	--sShowMessage(pDlg, "目前该网址并不支持解析，请更新解析脚本或自行编写。");
	--return tbl_re;
end


function getTaskAttributeBatch_Custom(str_url, str_tmpfile, str_servername, pDlg)
	local tbl_re = {};
	--if string.find(str_url, "acfun.cn", 1, true)~=nil or string.find(str_url, "124.228.254.234", 1, true)~=nil or string.find(str_url, str_servername, 1, true)~=nil
	--then
	--	return getTaskAttributeBatch_acfun(str_url, str_tmpfile, str_servername, pDlg);
	--end
	--[[you can add some scripts like above]]
	--add script here


	--end add

	sShowMessage(pDlg, "目前该网址并不支持解析，请更新解析脚本或自行编写。");
	return tbl_re;
end

