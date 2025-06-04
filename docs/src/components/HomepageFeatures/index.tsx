import type {JSX, ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<'svg'>>;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Seamless Supabase Integration',
    Svg: require('@site/static/img/01_create.svg').default,
    description: (
      <>
        Flutter Tether simplifies connecting your Flutter app to Supabase,
        automating local database mirroring and Dart model generation from your schema.
      </>
    ),
  },
  {
    title: 'Focus on Your App Logic',
    Svg: require('@site/static/img/02_build.svg').default,
    description: (
      <>
        Let Tether handle the complexities of data synchronization, caching,
        optimistic updates, and conflict resolution. You focus on building great features.
      </>
    ),
  },
  {
    title: 'Powerful & Flexible',
    Svg: require('@site/static/img/03_features.svg').default,
    description: (
      <>
        Leverage robust query builders, real-time data streaming, and helpful utilities for common tasks like auth and feeds.
      </>
    ),
  },
];

function Feature({title, Svg, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
