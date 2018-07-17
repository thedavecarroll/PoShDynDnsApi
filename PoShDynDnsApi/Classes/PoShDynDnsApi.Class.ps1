class DynDnsRawData {
    hidden [PSCustomObject]$RawData
}

class DynDnsRecord : DynDnsRawData {
    [string]$Zone
    [string]$Name
    [string]$Type
    [int]$TTL
    hidden [string]$RecordId

    DynDnsRecord () {}
    DynDnsRecord ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_A : DynDnsRecord {
    #IPv4Address
    [ipaddress]$Address

    DynDnsRecord_A () {  }
    DynDnsRecord_A ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.TTL = $DnsRecord.ttl
        $this.Address = $DnsRecord.rdata.address
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_TXT : DynDnsRecord {
    [string[]]$Strings

    DynDnsRecord_TXT () {  }
    DynDnsRecord_TXT ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.Strings = $DnsRecord.rdata.txtdata
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_CNAME : DynDnsRecord {
    [string]$NameHost

    DynDnsRecord_CNAME () {  }
    DynDnsRecord_CNAME ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.NameHost = $DnsRecord.rdata.cname
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_MX : DynDnsRecord {
    [string]$Exchange
    [int]$Preference

    DynDnsRecord_MX () {  }
    DynDnsRecord_MX ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.Exchange = $DnsRecord.rdata.exchange
        $this.Preference = $DnsRecord.rdata.preference
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_SRV : DynDnsRecord {
    #NameTarget
    [string]$Target
    [int]$Port
    [int]$Priority
    [int]$Weight

    DynDnsRecord_SRV () {  }
    DynDnsRecord_SRV ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.Target = $DnsRecord.rdata.target
        $this.Port = $DnsRecord.rdata.port
        $this.Priority = $DnsRecord.rdata.priority
        $this.Weight = $DnsRecord.rdata.weight
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_PTR : DynDnsRecord {
    [string]$NameHost

    DynDnsRecord_PTR () {  }
    DynDnsRecord_PTR ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.NameHost = $DnsRecord.rdata.ptrdname
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_NS : DynDnsRecord {
    #Server
    [string]$NameHost
    [string]$Authoritative

    DynDnsRecord_NS () {  }
    DynDnsRecord_NS ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.NameHost = $DnsRecord.rdata.nsdname
        $this.Authoritative = $DnsRecord.service_class
        $this.TTL = $DnsRecord.ttl
        $this.RecordId = $DnsRecord.record_id
        $this.RawData = $DnsRecord
    }
}

class DynDnsRecord_SOA : DynDnsRecord {
    #NameAdministrator
    [string]$Administrator
    [int]$SerialNumber
    [string]$PrimaryServer
    [int]$TimeToExpiration
    [int]$TimeToZoneFailureRetry
    [int]$TimeToZoneRefresh
    [int]$DefaultTTL

    DynDnsRecord_SOA () {  }
    DynDnsRecord_SOA ([PSCustomObject]$DnsRecord) {
        $this.Zone = $DnsRecord.zone
        $this.Name = $DnsRecord.fqdn
        $this.Type = $DnsRecord.record_type
        $this.Administrator = $DnsRecord.rdata.rname
        $this.SerialNumber = $DnsRecord.rdata.serial
        $this.PrimaryServer = $DnsRecord.rdata.mname
        $this.TimeToExpiration = $DnsRecord.rdata.expire
        $this.TimeToZoneFailureRetry = $DnsRecord.rdata.retry
        $this.TimeToZoneRefresh = $DnsRecord.rdata.refresh
        $this.DefaultTTL = $DnsRecord.rdata.minimum
        $this.TTL = $DnsRecord.ttl
        $this.RawData = $DnsRecord
    }
}

class DynDnsTask : DynDnsRawData {
    [int]$TaskId
    [object]$Created
    [object]$Modified
    [string]$CustomerName
    [string]$Zone
    [string]$TaskName
    [string]$Status
    [string]$Message
    [string]$Blocking
    [int]$Steps
    [int]$StepCount
    [object[]]$Arugments
    [string]$Debug

    DynDnsTask () {  }
    DynDnsTask ([PSCustomObject]$DynTask) {
        [datetime]$origin = '1970-01-01 00:00:00'

        $this.TaskId = $DynTask.task_id
        $this.Created = $origin.AddSeconds($DynTask.created_ts).ToLocalTime()
        $this.Modified = $origin.AddSeconds($DynTask.modified_ts).ToLocalTime()
        $this.CustomerName = $DynTask.customer_name
        $this.Zone = $DynTask.zone_name
        $this.TaskName = $DynTask.name
        $this.Status = $DynTask.status
        $this.Message = $DynTask.message
        $this.Blocking = $DynTask.blocking
        $this.Steps = $DynTask.total_steps
        $this.StepCount = $DynTask.step_count
        $this.Arugments = $DynTask.args
        $this.Debug = $DynTask.debug
        $this.RawData = $DynTask
    }
}

class DynDnsZone : DynDnsRawData {
    [string]$Zone
    [int]$SerialNumber
    [string]$SerialStyle
    [string]$Type

    DynDnsZone () {  }
    DynDnsZone ([PSCustomObject]$DynDnsZone) {
        $this.Zone = $DynDnsZone.zone
        $this.SerialNumber = $DynDnsZone.serial
        $this.SerialStyle = $DynDnsZone.serial_style
        $this.Type = $DynDnsZone.zone_type
        $this.RawData = $DynDnsZone
    }
}

class DynDnsZoneNote : DynDnsRawData {
    [string]$Zone
    [object]$Timestamp
    [string]$Type
    [string]$User
    [string]$SerialNumber
    [string]$Note

    DynDnsZoneNote () {  }
    DynDnsZoneNote ([PSCustomObject]$DynDnsZoneNote) {
        [datetime]$origin = '1970-01-01 00:00:00'

        $this.Zone = $DynDnsZoneNote.zone
        $this.Timestamp = $origin.AddSeconds($DynDnsZoneNote.timestamp).ToLocalTime()
        $this.Type = $DynDnsZoneNote.type
        $this.User = $DynDnsZoneNote.user_name
        $this.SerialNumber = $DynDnsZoneNote.serial
        $this.Note = $DynDnsZoneNote.note.trim()
        $this.RawData = $DynDnsZoneNote
    }
}

class DynDnsHttpRedirect  : DynDnsRawData {
    [string]$Zone
    [string]$Name
    [string]$Url
    [string]$ResponseCode
    [object]$IncludeUri

    DynDnsHttpRedirect () {  }
    DynDnsHttpRedirect ([PSCustomObject]$DynDnsHttpRedirect) {
        if ($DynDnsHttpRedirect.keep_uri -match 'Y') {
            $KeepUri = $true
        } else {
            $KeepUri = $false
        }
        $this.Zone = $DynDnsHttpRedirect.zone
        $this.Name = $DynDnsHttpRedirect.fqdn
        $this.Url = $DynDnsHttpRedirect.url
        $this.ResponseCode = $DynDnsHttpRedirect.code
        $this.IncludeUri = $KeepUri
        $this.RawData = $DynDnsHttpRedirect
    }
}

class DynDnsUser : DynDnsRawData {
    [string]$UserName
    [string]$Status
    [string]$CustomerName
    [string]$Nickname
    [string]$FirstName
    [string]$LastName
    [string]$Email
    [string]$Phone
    [string[]]$Groups

    DynDnsUser () {}
    DynDnsUser ([PSCustomObject]$DynDnsUser) {
        $this.UserName = $DynDnsUser.user_name
        $this.Status = $DynDnsUser.status
        $this.CustomerName = $DynDnsUser.organization
        $this.Nickname = $DynDnsUser.nickname
        $this.FirstName = $DynDnsUser.first_name
        $this.LastName = $DynDnsUser.last_name
        $this.Email = $DynDnsUser.email
        $this.Phone = $DynDnsUser.phone
        $this.Groups = $DynDnsUser.group_name
        $this.RawData = $DynDnsUser
    }
}
