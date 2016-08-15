# Delay to make sure HW start up correctly before scanning
:delay 10s;
{
# Enter the name of the actual wireless interface, not a virtual one
  :local wlanInterface [/interface wireless find name="wlan1-LAN"]
  :local executeBackground false
  :if ($wlanInterface = "") do={
    :log error "Need to set a interface name"
  }
  :local scanList "scan_list.csv"
  :local lineEnd 0
  :local lastEnd 0
  :local connectList value=[:toarray ""]
  :local currentFrequency [/interface wireless get $wlanInterface frequency]
  :local strongestRssi -127
  :local strongestFreq $currentFrequency
  :foreach element in=[/interface wireless connect-list print as-value where disabled=no] do={ 
    :set $connectList ($connectList, $element->"ssid")
  }
  :if ($executeBackground = true) do={
    :local j [:execute {/interface wireless scan $wlanInterface background=yes duration=5 rounds=1 save-file=$scanList;}]
    :delay 6s
    :if ($j != nil) do={ :do {/system script job remove $j } on-error={:log info "Failed to stop job"}}
  } else={
    /interface wireless scan $wlanInterface background=yes duration=5 rounds=1 save-file=$scanList
    :delay 4s
  }
  :do {
    :local content [/file get $scanList contents]
# Remove the file after loading it to memory
    /file remove [find name=$scanList]
    :local contentLen [:len $content]
# While loop to itereate trough the lines of the scan file
    :while ($lineEnd < $contentLen) do={
      :set lineEnd [:find $content "\n" $lastEnd]
      :if ([:len $lineEnd] = 0) do={
        :set lineEnd $contentLen
      }
      :local line [:pick $content $lastEnd $lineEnd]
      :local myArr [:toarray $line]
      :set lastEnd ($lineEnd + 1)
# Parse the line for line in the scan list
      :local ssid [:pick $myArr 1]
      :local freq [:pick [:pick $myArr 2] 0 4]
      :local rssi [:tonum [:pick $myArr 3]]
      :set ssid [:pick $ssid 1 ([:len $ssid]-1)]
# For each element in the connect list, check if it match the SSID
      :foreach elSsid in=$connectList do={
        :if ($elSsid = $ssid) do={
          :if ($currentFrequency != $freq && $strongestRssi < $rssi) do={
            :set strongestFreq $freq
            :set strongestRssi $rssi
          }
        }
      }
    }
    if ($currentFrequency != $strongestFreq) do={
      :log info ("Found a better frequency ".$strongestFreq." for a network in the connect list")
      /interface wireless set $wlanInterface frequency=$strongestFreq
    } else={
      :log info "Already scanning on the best frequency"
    }
  } on-error={:log info "Did not get a scan list"}
}
