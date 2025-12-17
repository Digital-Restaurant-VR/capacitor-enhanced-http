export class CapacitorEnhancedHttpWeb {
    async unsafeGet() {
        throw new Error("unsafeGet not supported on web");
    }
    async unsafePost() {
        throw new Error("unsafePost not supported on web");
    }
}
