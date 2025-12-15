import { HttpHeaders } from "@capacitor/core";

export interface UnsafeResponse {
  status: number
  data: any
}

export interface EnhancedHttpPlugin {
  unsafeGet(options: { url: string; headers?: HttpHeaders }): Promise<UnsafeResponse>
  unsafePost(options: { url: string; headers?: HttpHeaders; data?: string }): Promise<UnsafeResponse>
}