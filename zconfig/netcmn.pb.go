// Code generated by protoc-gen-go. DO NOT EDIT.
// source: netcmn.proto

package zconfig

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

type DHCPType int32

const (
	DHCPType_DHCPNoop DHCPType = 0
	// used for device adapter
	DHCPType_Static DHCPType = 1
	// used for application simulation
	DHCPType_PassThrough DHCPType = 2
	// used for application simulation
	DHCPType_Server DHCPType = 3
	// used for device adapter
	DHCPType_Client DHCPType = 4
)

var DHCPType_name = map[int32]string{
	0: "DHCPNoop",
	1: "Static",
	2: "PassThrough",
	3: "Server",
	4: "Client",
}
var DHCPType_value = map[string]int32{
	"DHCPNoop":    0,
	"Static":      1,
	"PassThrough": 2,
	"Server":      3,
	"Client":      4,
}

func (x DHCPType) String() string {
	return proto.EnumName(DHCPType_name, int32(x))
}
func (DHCPType) EnumDescriptor() ([]byte, []int) { return fileDescriptor5, []int{0} }

type NetworkType int32

const (
	NetworkType_NETWORKTYPENOOP NetworkType = 0
	NetworkType_V4              NetworkType = 4
	NetworkType_V6              NetworkType = 6
	NetworkType_CryptoV4        NetworkType = 14
)

var NetworkType_name = map[int32]string{
	0:  "NETWORKTYPENOOP",
	4:  "V4",
	6:  "V6",
	14: "CryptoV4",
}
var NetworkType_value = map[string]int32{
	"NETWORKTYPENOOP": 0,
	"V4":              4,
	"V6":              6,
	"CryptoV4":        14,
}

func (x NetworkType) String() string {
	return proto.EnumName(NetworkType_name, int32(x))
}
func (NetworkType) EnumDescriptor() ([]byte, []int) { return fileDescriptor5, []int{1} }

type IpRange struct {
	Start string `protobuf:"bytes,1,opt,name=start" json:"start,omitempty"`
	End   string `protobuf:"bytes,2,opt,name=end" json:"end,omitempty"`
}

func (m *IpRange) Reset()                    { *m = IpRange{} }
func (m *IpRange) String() string            { return proto.CompactTextString(m) }
func (*IpRange) ProtoMessage()               {}
func (*IpRange) Descriptor() ([]byte, []int) { return fileDescriptor5, []int{0} }

func (m *IpRange) GetStart() string {
	if m != nil {
		return m.Start
	}
	return ""
}

func (m *IpRange) GetEnd() string {
	if m != nil {
		return m.End
	}
	return ""
}

// These are list of static mapping that can be added to network
type ZnetStaticDNSEntry struct {
	HostName string   `protobuf:"bytes,1,opt,name=HostName" json:"HostName,omitempty"`
	EID      []string `protobuf:"bytes,2,rep,name=EID" json:"EID,omitempty"`
}

func (m *ZnetStaticDNSEntry) Reset()                    { *m = ZnetStaticDNSEntry{} }
func (m *ZnetStaticDNSEntry) String() string            { return proto.CompactTextString(m) }
func (*ZnetStaticDNSEntry) ProtoMessage()               {}
func (*ZnetStaticDNSEntry) Descriptor() ([]byte, []int) { return fileDescriptor5, []int{1} }

func (m *ZnetStaticDNSEntry) GetHostName() string {
	if m != nil {
		return m.HostName
	}
	return ""
}

func (m *ZnetStaticDNSEntry) GetEID() []string {
	if m != nil {
		return m.EID
	}
	return nil
}

// Common for IPv4 and IPv6
type Ipspec struct {
	Dhcp DHCPType `protobuf:"varint,2,opt,name=dhcp,enum=DHCPType" json:"dhcp,omitempty"`
	// subnet is CIDR format...x.y.z.l/nn
	Subnet  string   `protobuf:"bytes,3,opt,name=subnet" json:"subnet,omitempty"`
	Gateway string   `protobuf:"bytes,5,opt,name=gateway" json:"gateway,omitempty"`
	Domain  string   `protobuf:"bytes,6,opt,name=domain" json:"domain,omitempty"`
	Ntp     string   `protobuf:"bytes,7,opt,name=ntp" json:"ntp,omitempty"`
	Dns     []string `protobuf:"bytes,8,rep,name=dns" json:"dns,omitempty"`
	// for IPAM management when dhcp is turned on.
	// If none provided, system will default pool.
	DhcpRange *IpRange `protobuf:"bytes,9,opt,name=dhcpRange" json:"dhcpRange,omitempty"`
}

func (m *Ipspec) Reset()                    { *m = Ipspec{} }
func (m *Ipspec) String() string            { return proto.CompactTextString(m) }
func (*Ipspec) ProtoMessage()               {}
func (*Ipspec) Descriptor() ([]byte, []int) { return fileDescriptor5, []int{2} }

func (m *Ipspec) GetDhcp() DHCPType {
	if m != nil {
		return m.Dhcp
	}
	return DHCPType_DHCPNoop
}

func (m *Ipspec) GetSubnet() string {
	if m != nil {
		return m.Subnet
	}
	return ""
}

func (m *Ipspec) GetGateway() string {
	if m != nil {
		return m.Gateway
	}
	return ""
}

func (m *Ipspec) GetDomain() string {
	if m != nil {
		return m.Domain
	}
	return ""
}

func (m *Ipspec) GetNtp() string {
	if m != nil {
		return m.Ntp
	}
	return ""
}

func (m *Ipspec) GetDns() []string {
	if m != nil {
		return m.Dns
	}
	return nil
}

func (m *Ipspec) GetDhcpRange() *IpRange {
	if m != nil {
		return m.DhcpRange
	}
	return nil
}

func init() {
	proto.RegisterType((*IpRange)(nil), "ipRange")
	proto.RegisterType((*ZnetStaticDNSEntry)(nil), "ZnetStaticDNSEntry")
	proto.RegisterType((*Ipspec)(nil), "ipspec")
	proto.RegisterEnum("DHCPType", DHCPType_name, DHCPType_value)
	proto.RegisterEnum("NetworkType", NetworkType_name, NetworkType_value)
}

func init() { proto.RegisterFile("netcmn.proto", fileDescriptor5) }

var fileDescriptor5 = []byte{
	// 404 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x44, 0x51, 0x5d, 0x6b, 0xdb, 0x30,
	0x14, 0xad, 0x93, 0xd4, 0x49, 0x6e, 0x4a, 0x2b, 0xb4, 0x31, 0xc4, 0xa0, 0x2c, 0xe4, 0x61, 0x94,
	0x3e, 0x38, 0xac, 0x2b, 0x7b, 0x2e, 0x4d, 0x0c, 0x2d, 0x63, 0x4e, 0x70, 0x43, 0xc7, 0xfa, 0xa6,
	0xc8, 0x9a, 0x23, 0x56, 0x4b, 0x42, 0x92, 0x5b, 0xdc, 0xff, 0xb6, 0xff, 0x36, 0x24, 0xa5, 0xeb,
	0x93, 0xef, 0xb9, 0x1f, 0xe7, 0x1c, 0x1f, 0xc1, 0x91, 0xe4, 0x8e, 0x35, 0x32, 0xd3, 0x46, 0x39,
	0x35, 0xfb, 0x02, 0x43, 0xa1, 0x4b, 0x2a, 0x6b, 0x8e, 0xdf, 0xc3, 0xa1, 0x75, 0xd4, 0x38, 0x92,
	0x4c, 0x93, 0xb3, 0x71, 0x19, 0x01, 0x46, 0xd0, 0xe7, 0xb2, 0x22, 0xbd, 0xd0, 0xf3, 0xe5, 0xec,
	0x1a, 0xf0, 0x83, 0xe4, 0xee, 0xce, 0x51, 0x27, 0xd8, 0xb2, 0xb8, 0xcb, 0xa5, 0x33, 0x1d, 0xfe,
	0x08, 0xa3, 0x1b, 0x65, 0x5d, 0x41, 0x1b, 0xbe, 0x27, 0xf8, 0x8f, 0x3d, 0x47, 0x7e, 0xbb, 0x24,
	0xbd, 0x69, 0xdf, 0x73, 0xe4, 0xb7, 0xcb, 0xd9, 0xdf, 0x04, 0x52, 0xa1, 0xad, 0xe6, 0x0c, 0x9f,
	0xc2, 0xa0, 0xda, 0x31, 0x1d, 0x14, 0x8e, 0x2f, 0xc6, 0xd9, 0xf2, 0x66, 0xb1, 0xde, 0x74, 0x9a,
	0x97, 0xa1, 0x8d, 0x3f, 0x40, 0x6a, 0xdb, 0xad, 0xe4, 0x8e, 0xf4, 0x03, 0xeb, 0x1e, 0x61, 0x02,
	0xc3, 0x9a, 0x3a, 0xfe, 0x4c, 0x3b, 0x72, 0x18, 0x06, 0xaf, 0xd0, 0x5f, 0x54, 0xaa, 0xa1, 0x42,
	0x92, 0x34, 0x5e, 0x44, 0xe4, 0x5d, 0x48, 0xa7, 0xc9, 0x30, 0xfe, 0x89, 0x74, 0xda, 0x77, 0x2a,
	0x69, 0xc9, 0x28, 0xfa, 0xaa, 0xa4, 0xc5, 0x9f, 0x61, 0xec, 0x55, 0x43, 0x20, 0x64, 0x3c, 0x4d,
	0xce, 0x26, 0x17, 0xa3, 0x6c, 0x1f, 0x50, 0xf9, 0x36, 0x3a, 0xff, 0x01, 0xa3, 0x57, 0x9f, 0xf8,
	0x28, 0xd6, 0x85, 0x52, 0x1a, 0x1d, 0x60, 0x80, 0x34, 0x26, 0x83, 0x12, 0x7c, 0x02, 0x93, 0x35,
	0xb5, 0x76, 0xb3, 0x33, 0xaa, 0xad, 0x77, 0xa8, 0x17, 0x86, 0xdc, 0x3c, 0x71, 0x83, 0xfa, 0xbe,
	0x5e, 0x3c, 0x0a, 0x2e, 0x1d, 0x1a, 0x9c, 0x5f, 0xc1, 0xa4, 0xe0, 0xee, 0x59, 0x99, 0x3f, 0x81,
	0xf1, 0x1d, 0x9c, 0x14, 0xf9, 0xe6, 0xe7, 0xaa, 0xfc, 0xbe, 0xf9, 0xb5, 0xce, 0x8b, 0xd5, 0x6a,
	0x8d, 0x0e, 0x70, 0x0a, 0xbd, 0xfb, 0x4b, 0x34, 0x08, 0xdf, 0x6f, 0x28, 0xf5, 0xb2, 0x0b, 0xd3,
	0x69, 0xa7, 0xee, 0x2f, 0xd1, 0xf1, 0xf5, 0x15, 0x7c, 0x62, 0xaa, 0xc9, 0x5e, 0x78, 0xc5, 0x2b,
	0x9a, 0xb1, 0x47, 0xd5, 0x56, 0x59, 0x6b, 0xb9, 0x79, 0x12, 0x8c, 0xc7, 0xa7, 0x7e, 0x38, 0xad,
	0x85, 0xdb, 0xb5, 0xdb, 0x8c, 0xa9, 0x66, 0x1e, 0xf7, 0xe6, 0x54, 0x8b, 0xf9, 0x0b, 0x53, 0xf2,
	0xb7, 0xa8, 0xb7, 0x69, 0xd8, 0xfa, 0xfa, 0x2f, 0x00, 0x00, 0xff, 0xff, 0x9e, 0x42, 0x43, 0x20,
	0x20, 0x02, 0x00, 0x00,
}
