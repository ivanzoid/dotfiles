"use strict";(("undefined"!=typeof self?self:global).webpackChunkopen=("undefined"!=typeof self?self:global).webpackChunkopen||[]).push([[8785],{79656:(e,s,r)=>{r.d(s,{h:()=>x});var i=r(73809),t=r(60926),a=r(66197),n=r(64266),c=r(52171),l=r(34466),o=r(73327),u=r(1510),d=r(82895),h=r(2098),m=r(92910),g=r(4637);const x=({entity:e,index:s,testId:r,onClick:x,isHero:I=!1})=>{switch(e.type){case m.p.ALBUM:return(0,g.jsx)(i.r,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,artists:e.artists,year:e.year,sharingInfo:null,requestId:e.requestId,color:e.color},e.uri);case m.p.ARTIST:return(0,g.jsx)(t.I,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,requestId:e.requestId,color:e.color},e.uri);case m.p.AUDIOBOOK:return(0,g.jsx)(a.c,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,authorName:e.authorName,requestId:e.requestId,color:e.color},e.uri);case m.p.EPISODE:return(0,g.jsx)(c.B,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,showImages:e.show.images,durationMilliseconds:e.duration.milliseconds,releaseDate:e.release.date,resume_point:null,description:e.description,isExplicit:e.isExplicit,is19PlusOnly:e.is19PlusOnly,sharingInfo:null,requestId:e.requestId,color:e.color},e.uri);case m.p.GENRE:return(0,g.jsx)(l.s,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,requestId:e.requestId,color:e.color},e.uri);case m.p.PLAYLIST:return(0,g.jsx)(o.Z,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,description:"",authorName:e.owner.displayName,requestId:e.requestId,color:e.color},e.uri);case m.p.USER:return(0,g.jsx)(u.P,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,requestId:e.requestId,color:e.color},e.uri);case m.p.SHOW:return(0,g.jsx)(d._,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.images,publisher:e.publisher,sharingInfo:null,requestId:e.requestId,color:e.color},e.uri);case m.p.TRACK:return(0,g.jsx)(h.G,{testId:r,onClick:x,isHero:I,index:s,name:e.name,uri:e.uri,images:e.album?.images||[],artists:e.artists,album:e.album,isExplicit:e.isExplicit,is19PlusOnly:e.is19PlusOnly,sharingInfo:null,requestId:e.requestId,isLyricsMatch:e.isLyricsMatch,color:e.color},e.uri);default:return console.warn('Rendering SearchEntityCard using the old method <DeprecatedEntityCardByUriType /> as the entity doesn\'t contain the new "type" EntityType enum.'),(0,g.jsx)(n.q,{testId:r,onClick:x,isHero:I,index:s,entity:e})}}},41608:(e,s,r)=>{r.d(s,{q:()=>u});var i=r(46455),t=r(25007),a=r(79656);const n="x-searchHistoryEntries-searchHistoryEntry",c="x-searchHistoryEntries-clearSingleSearchHistory",l="x-searchHistoryEntries-clearSingleSearchHistoryButton";var o=r(4637);const u=({entity:e,index:s,clearSearchHistory:r})=>(0,o.jsxs)("div",{className:n,children:[(0,o.jsx)(a.h,{entity:{...e,requestId:void 0},index:s}),(0,o.jsx)("div",{className:c,children:(0,o.jsx)("button",{className:l,onClick:()=>r(e.uri),"aria-label":t.ag.get("remove"),children:(0,o.jsx)(i.k,{iconSize:16})})})]},e.uri)},79966:(e,s,r)=>{r.r(s),r.d(s,{default:()=>b});var i=r(84875),t=r.n(i),a=r(83600),n=r(25007),c=r(59496),l=r(87518),o=r(88778),u=r(2405),d=r(41608),h=r(29009),m=r(77003),g=r(77899),x=r(32364);const I="Ul_eSpTV7OKDhvXcgfzw",p="HFNTjI36ujrPacyLOwTT";var y=r(4637);const j=()=>{const{searchHistory:e,clearSearchHistory:s}=(0,x.u)(),r=(0,l.s0)(),{spec:i,logger:t,UBIFragment:a}=(0,m.fU)(u.createDesktopRecentSearchesEventFactory,{data:{uri:"spotify:app:recent-searches"}}),j=(0,c.useMemo)((()=>i.recentSearchesCardsFactory()),[i]),k=(0,c.useCallback)((()=>{const e=i.clearButtonFactory().hitClearRecentSearches();t.logInteraction(e),s(),r("/search")}),[s,t,r,i]),q=(0,c.useCallback)((i=>{const t=e.length;s(i),1===t&&r("/search")}),[s,r,e.length]);return 0===e.length?null:(0,y.jsxs)("div",{className:I,children:[(0,y.jsx)(a,{spec:j,children:(0,y.jsx)(g.P,{title:n.ag.get("search.title.recent-searches"),showAll:!0,children:e.map(((e,s)=>(0,y.jsx)(h.ZP,{index:s,value:"search-history",children:(0,y.jsx)(d.q,{clearSearchHistory:q,entity:e,index:s})},e.uri)))})}),(0,y.jsx)("button",{onClick:k,className:p,children:(0,y.jsx)(o.D,{variant:"minuetBold",children:n.ag.get("search.clear-recent-searches")})})]})};var k=r(33428),q=r(31716),C=r(41818);const f=()=>{const e=(0,a.W6)(k.Dz);return(0,y.jsxs)(h.ZP,{value:"search-page",children:[(0,y.jsx)(q.$,{children:n.ag.get("search.page-title")}),(0,y.jsx)("div",{className:t()("contentSpacing",{[C.Z.narrowPage]:e}),id:"searchPage",children:(0,y.jsx)(j,{})})]})},b=f},41818:(e,s,r)=>{r.d(s,{Z:()=>i});const i={searchPageGrid:"search-recentSearches-searchPageGrid",narrowPage:"search-recentSearches-narrowPage"}}}]);
//# sourceMappingURL=xpui-routes-recent-searches.js.map