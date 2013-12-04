package org.gbif.portal.action.participation;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Node;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.NodeType;
import org.gbif.api.vocabulary.ParticipationStatus;
import org.gbif.portal.action.BaseAction;

import java.util.List;
import java.util.UUID;
import javax.annotation.Nullable;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.Lists;
import com.google.common.collect.Ordering;
import com.google.inject.Inject;

/**
 * Landing page for non country nodes.
 */
public class ListAction extends BaseAction {
  public static final UUID GBIF_TEMP_NODE_KEY = UUID.fromString("02c40d2a-1cba-4633-90b7-e36e5e97aba8");

  private List<Node> voting = Lists.newArrayList();
  private List<Node> associate = Lists.newArrayList();
  private List<Node> other = Lists.newArrayList();

  @Inject
  private NodeService nodeService;

  @Override
  public String execute() throws Exception {
    PagingResponse<Node> resp = nodeService.list(new PagingRequest(0, 1000));
    List<Node> sorted = FluentIterable.from(resp.getResults())
      // sort alphabetically
      .filter(new Predicate<Node>() {
        public boolean apply(@Nullable Node n) {
          return !GBIF_TEMP_NODE_KEY.equals(n.getKey());
        }
      })
      .toSortedList(Ordering.natural().nullsLast().onResultOf(new Function<Node, Country>() {
        @Nullable
        @Override
        public Country apply(@Nullable Node n) {
          return n == null ? null : n.getCountry();
        }
      }));

    for (Node n: sorted) {
      if (GBIF_TEMP_NODE_KEY.equals(n.getKey())) {
        continue;
      }
      if (NodeType.COUNTRY == n.getType()) {
        if (ParticipationStatus.VOTING == n.getParticipationStatus()) {
          voting.add(n);
        } else if (ParticipationStatus.ASSOCIATE == n.getParticipationStatus()) {
          associate.add(n);
        }
      } else if (ParticipationStatus.ASSOCIATE == n.getParticipationStatus()){
        other.add(n);
      }
    }

    // sort others according to node title, in case of taiwan use the country title
    other = FluentIterable.from(other)
      // sort alphabetically
      .toSortedList(Ordering.natural().nullsLast().onResultOf(new Function<Node, String>() {
        @Nullable
        @Override
        public String apply(@Nullable Node n) {
          // yet another taiwan country hack: http://dev.gbif.org/issues/browse/PF-1031
          return n == null ? null : (n.getCountry()==Country.TAIWAN ? Country.TAIWAN.getTitle() : n.getTitle()) ;
        }
      }));

    return SUCCESS;
  }

  public List<Node> getVoting() {
    return voting;
  }

  public List<Node> getAssociate() {
    return associate;
  }

  public List<Node> getOther() {
    return other;
  }
}
