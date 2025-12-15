# Capacitor-enhanced-http

This capacitor plugin lets you make unsafe HTTPS requests ignoring SSL verification, which can be useful in specific local development or provisioning scenarios where certificates are self-signed or not trusted by the system.

> ❗ Important: Disabling SSL certificate validation undermines one of the primary protections HTTPS provides. It should only be used in controlled, trusted environments (e.g., local devices on a closed network during provisioning).

---

## 💡 What It Does

By default, mobile platforms enforce SSL/TLS certificate validation.

That means HTTPS requests will fail if:

- the certificate is self-signed,
- the certificate chain is incomplete,
- the hostname/IP doesn’t match the certificate’s SAN/CN.

This plugin bypasses that validation so requests can succeed even in those conditions.

---

## ⚠️ Security Implications

Ignoring SSL certificate checks is dangerous if used outside of very specific, controlled scenarios:

What SSL/TLS Normally Protects

- Encryption of data in transit
- Assurance that the server is who it claims to be
- Protection against man-in-the-middle (MITM) attacks

When bypassing certificate validation, these protections are lost.

An attacker in the same network could:

- intercept requests,
- read or modify sensitive data,
- impersonate endpoints.

## ⚠️ Platform Policy Risks

**App Store / Google Play**

Disabling TLS validation across an app — especially if not limited to a very specific local use case — can raise policy and review issues with both Apple and Google:

- Apple’s platform security guidelines emphasize secure network communication.
- Bypassing certificate validation globally could be interpreted as a deliberate security weakening.
- Review teams may question apps that ignore SSL without clear justification.

Industry best practices (like SSL pinning) exist because real production apps shouldn’t trust arbitrary certificates. ￼

---

## 🧪 Use Cases

This plugin may be appropriate when:

✅ You are communicating with a local device (e.g., IoT provisioning) inside a trusted network

✅ The device uses a self-signed certificate and cannot be updated to use a CA-trusted one

✅ You explicitly restrict this behavior to a controlled portion of your app

## 🛑 Not Appropriate For

❌ Production traffic to external APIs

❌ User authentication flows or payment APIs

❌ Apps that send sensitive user data over untrusted networks

---

## Example

```ts
import { CapacitorEnhancedHttp as UnsafeHttp } from "capacitor-enhanced-http";

const response = await UnsafeHttp.unsafeGet({
  url: "https://192.168.10.1/api/system",
  headers: { Authorization: "Bearer token" },
});
```

Use this pattern only in scenarios where you can accept the security trade-off.