function Init()
	local m = NewWebsiteModule()
	m.ID                       = '268801f2a1404fe3a24bc8932e7a1b4a'
	m.Name                     = 'MangaDexToday'
	m.RootURL                  = 'https://mangadex.today'
	m.Category                 = 'English'
	m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
	m.OnGetNameAndLink         = 'GetNameAndLink'
	m.OnGetInfo                = 'GetInfo'
	m.OnGetPageNumber          = 'GetPageNumber'
end

local dirurl = '/popular-manga'

function GetDirectoryPageNumber()
	if HTTP.GET(MODULE.RootURL .. dirurl) then
		PAGENUMBER = tonumber(CreateTXQuery(HTTP.Document).x.XPathString('//ul[@class="pagination"]/li[./a/@rel="next"]/preceding-sibling::li[1]/a')) or 1
		return no_error
	else
		return net_problem
	end
end

function GetNameAndLink()
	local data = 'action=load_series_list_entries&parameter%5Bpage%5D=' .. (URL + 1) .. '&parameter%5Bletter%5D=&parameter%5Bsortby%5D=alphabetic&parameter%5Border%5D=asc'
	local s = MODULE.RootURL .. dirurl
	if URL ~= '0' then
		s = s .. '?page=' .. (URL + 1)
	end
	if HTTP.GET(s) then
		local x = CreateTXQuery(HTTP.Document)
		local v for v in x.XPath('//li/div/div[@class="left"]/a').Get() do
			LINKS.Add(v.GetAttribute('href'))
			NAMES.Add(x.XPathString('./h2', v))
		end
		return no_error
	else
		return net_problem
	end
end

function GetInfo()
	MANGAINFO.URL=MaybeFillHost(MODULE.RootURL,URL)
	if HTTP.GET(MANGAINFO.URL) then
		x=CreateTXQuery(HTTP.Document)
		MANGAINFO.Title     = x.XPathString('//h1[@itemprop="name"]')
		MANGAINFO.CoverLink = x.XPathString('//div[@class="imgdesc"]/img/@src')
		MANGAINFO.Authors   = x.XPathString('//div[@class="listinfo"]//li[contains(.,"Author")]/substring-after(.,":")')
		MANGAINFO.Summary   = x.XPathString('//div[@id="noidungm"]');
		MANGAINFO.Genres    = x.XPathStringAll('//div[@class="listinfo"]//li[contains(., "Genres")]/a')
		MANGAINFO.Status    = MangaInfoStatusIfPos((x.XPathString('//div[@class="listinfo"]//li[contains(.,"Status")]')))
		local chapters=x.XPath('//div[@class="cl"]//li/span')
		for i=1,chapters.Count do
			MANGAINFO.ChapterLinks.Add(x.XPathString('a/@href',chapters.Get(i)))
			MANGAINFO.ChapterNames.Add(x.XPathString('.',chapters.Get(i)))
		end
		MANGAINFO.ChapterLinks.Reverse(); MANGAINFO.ChapterNames.Reverse()
		return no_error
	else
		return net_problem
	end
end

function GetPageNumber()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL,URL .. '/0')) then
		CreateTXQuery(HTTP.Document).XPathStringAll('//div[@id="readerarea"]/img/@src', TASK.PageLinks)
		return true
	else
		return false
	end
end
