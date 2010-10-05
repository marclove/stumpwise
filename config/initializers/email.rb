RegEmailName   = '[\w\.%\+\-]+'
RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
RegDomainTLD   = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
