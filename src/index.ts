import { registerPlugin } from '@capacitor/core'
import type { EnhancedHttpPlugin } from './definitions'

const EnhancedHttp = registerPlugin<EnhancedHttpPlugin>('CapacitorEnhancedHttp')

export * from './definitions'
export default EnhancedHttp