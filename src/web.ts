export class CapacitorEnhancedHttpWeb {
  async unsafeGet(): Promise<any> {
    throw new Error("unsafeGet not supported on web");
  }
  async unsafePost(): Promise<any> {
    throw new Error("unsafePost not supported on web");
  }
}