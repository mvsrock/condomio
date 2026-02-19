import { OnlyDatePipe } from './only-date.pipe';

describe('OnlyDatePipe', () => {
  it('create an instance', () => {
    const pipe = new OnlyDatePipe();
    expect(pipe).toBeTruthy();
  });
});
